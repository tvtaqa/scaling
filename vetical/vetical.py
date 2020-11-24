import math
import random
import time
from kubernetes import client, config
from sympy import *
import yaml

_YAML_FILE_NAME = 'arg.yaml'

'''
输入：无
输出：无
描述：每隔120s去检测负载的变化
     若负载有变化，则推荐一个新的方案
'''


def decide(loadfromtxt, rpsfromtxt, limitfromtxt, arg):
    p_cpu = arg['p_cpu']
    interval = arg['interval']
    service_price = arg['p_service']
    rtt = arg['rtt']

    # 当前方案的信息,其中cpu_limit=_cpu_request,不考虑内存
    current_num_pod = 1
    current_rps_pod = 70.1
    current_limit_pod = 1950
    current_ws = 0.0
    current_sla_cost = 0
    current_rescource_cost = current_limit_pod*1000 * p_cpu
    current_total_cost = current_rescource_cost + current_sla_cost
    current_probaility = 0

    # 推荐方案的信息,其中cpu_limit=_cpu_request,不考虑内存
    recommend_num_pod = 1
    recommend_rps_pod = -1.0
    recommend_limit_pod = 1
    recommend_ws = 0.0
    recommend_sla_cost = 0
    recommend_rescource_cost = 0
    recommend_total_cost = 0
    recommend_probaility = 0

    loadcount = 0
    while True:

        '''
        是否使用最新推荐的方案,默认是否。如果变为是，有以下两种情况
        1.新负载下，会出现无限排队
        2.新的组合式伸缩方案比当前的组合式伸缩方案资源总量少了20%以上
        '''
        turn = -1

        # 获取最新的负载
        load = loadfromtxt[loadcount]
        # load = random.randint(50,300)

        # 判断维持当前方案是否会出现无限排队现象，若出现，则需要使用推荐方案
        if load / current_rps_pod >= 1:
            current_sla_cost = service_price
            current_ws = -1
            current_probaility = -1
        else:
            # 重新计算总成本。其中SLA违约成本会改变
            current_ws, current_probaility = getRTT(load, current_rps_pod, rtt, 1)
            if current_probaility > 99:
                current_sla_cost = 0
            elif current_probaility > 95:
                current_sla_cost = 0.1 * service_price
            elif current_probaility > 90:
                current_sla_cost = 0.3 * service_price
            else:
                current_sla_cost = service_price
            current_rescource_cost = current_limit_pod / 1000 * p_cpu
            current_total_cost = current_rescource_cost + current_sla_cost

        # 最少资源总量
        totalcost_min = 99999

        # the cycle for finding the best descision
        # 对于上述的load，推荐一个最优的方案，目标是资源成本最低
        historycount = 0
        while historycount < len(rpsfromtxt):
            tmp_limit = limitfromtxt[historycount]
            tmp_rps = rpsfromtxt[historycount]
            tmp_ws = -1
            tmp_pro = -1
            if load / tmp_rps >= 1:
                turn = -1
            else:
                turn = 0
                tmp_ws, tmp_pro = getRTT(load, tmp_rps, rtt, 1)
                tmp_sla_cost = -1
                if tmp_pro > 99:
                    tmp_sla_cost = 0
                elif tmp_pro > 95:
                    tmp_sla_cost = 0.1 * service_price
                elif tmp_pro > 90:
                    tmp_sla_cost = 0.3 * service_price
                else:
                    tmp_sla_cost = service_price
                tmp_rescource_cost = 1 * tmp_limit / 1000 * p_cpu
                tmp_total_cost = tmp_sla_cost + tmp_rescource_cost
                if totalcost_min > tmp_total_cost:
                    totalcost_min = tmp_total_cost
                    recommend_total_cost = tmp_total_cost
                    recommend_num_pod = 1
                    recommend_limit_pod = tmp_limit
                    recommend_rps_pod = tmp_rps
                    recommend_ws = tmp_ws
                    recommend_sla_cost = tmp_sla_cost
                    recommend_rescource_cost = tmp_rescource_cost
                    recommend_probaility = tmp_pro
                pass
            historycount = historycount + 1
        pass

        # 推荐的方案和当前使用的方案进行抉择
        if turn == 0 :
            percentage = abs(recommend_total_cost - current_total_cost) / current_total_cost
            if percentage > 0.2:
                turn = 1
            else :
                turn = -1
        if turn == 1 :
            # 执行最新推荐的伸缩方案
            # execute(1, recommend_limit_pod, arg)
            print("使用新的推荐方案：")
            print("load:%d" % load)
            print("num_pod :%d" % recommend_num_pod)
            print("limit_pod :%d" % recommend_limit_pod)
            print("rps_pod :%f" % recommend_rps_pod)
            print("ws_pod :%f" % recommend_ws)
            print("ws_pro :%f" % recommend_probaility)
            current_num_pod = recommend_num_pod
            current_rps_pod = recommend_rps_pod
            current_limit_pod = recommend_limit_pod
            current_ws = recommend_ws
            current_probaility = recommend_probaility
            current_rescource_cost = recommend_rescource_cost
            current_sla_cost = recommend_sla_cost
            current_total_cost = recommend_total_cost
        elif turn == -1:
            print("维持当前的方案：")
            print("load:%d" % load)
            print("num_pod :%d" % current_num_pod)
            print("limit_pod :%d" % current_limit_pod)
            print("rps_pod :%f" % current_rps_pod)
            print("ws_pod :%f" % current_ws)
            print("ws_pro :%f" % current_probaility)

        print(time.strftime("%Y-%m-%d %H:%M:%S", time.localtime()))
        print("*" * 30)

        # time.sleep(interval)
        loadcount = loadcount + 1
        if loadcount >= len(loadfromtxt):
            print("伸缩测试结束")
            break
        pass


'''
输入：pod的个数、request(limit和request相同)
输出：无
描述：执行组合式伸缩的方案
'''


def execute(num_pod, limit_pod, arg):
    config.load_kube_config()
    api_instance = client.AppsV1Api()
    deployment = arg['deployment']
    namespace = arg['namespace']
    deployobj = api_instance.read_namespaced_deployment(deployment, namespace)

    # 执行伸缩方案
    recommend_cpu_requests = int(1.0 * limit_pod / 3)
    # recommend_mem_requests = 200
    recommend_cpu_limits = int(limit_pod)
    # recommend_mem_limits = 200
    recommend_requests = {
        'cpu': str(recommend_cpu_requests) + 'm',
        # 'memory': str(recommend_mem_requests) + 'Mi'
    }
    recommend_limits = {
        'cpu': str(recommend_cpu_limits) + 'm',
        # 'memory': str(recommend_mem_limits) + 'Mi'
    }
    deployobj.spec.template.spec.containers[0].resources.limits.update(recommend_limits)
    deployobj.spec.template.spec.containers[0].resources.requests.update(recommend_requests)
    deployobj.spec.replicas = num_pod
    api_instance.replace_namespaced_deployment(deployment, namespace, deployobj)

    # 伸缩完成后，查看伸缩是否完成
    current_replicas_num = deployobj.spec.replicas
    current_cpu_request = int(deployobj.spec.template.spec.containers[0].resources.requests.get('cpu').split('m')[0])
    currnet_mem_request = int(
        deployobj.spec.template.spec.containers[0].resources.requests.get('memory').split('Mi')[0])
    current_cpu_limit = int(deployobj.spec.template.spec.containers[0].resources.limits.get('cpu').split('m')[0])
    currnet_mem_limit = int(deployobj.spec.template.spec.containers[0].resources.limits.get('memory').split('Mi')[0])
    # print("伸缩已完成，方案如下：")

    # print("pod个数: %d " % current_replicas_num)
    # print("cpu_request: %dm" % current_cpu_request)
    # print("cpu_limit: %dm" % current_cpu_limit)
    # print("*"*30)


def getRTT(load, rps, rtt, c):
    strength = 1.0 * load / (c * rps)
    p0 = 0
    k = 0
    while k <= c - 1:
        p0 += (1.0 / math.factorial(k)) * ((1.0 * load / rps) ** k)
        k = k + 1

    p0 += (1.0 / math.factorial(c)) * (1.0 / (1 - strength)) * ((1.0 * load / rps) ** c)
    p0 = 1 / p0
    lq = ((c * strength) ** c) * strength / (math.factorial(c) * (1 - strength) * (1 - strength)) * p0
    ls = lq + load / rps
    ws = ls / load
    wq = lq / load

    pi_n = ((c * strength) ** c) / math.factorial(c) * p0
    tmp = (math.e ** ((rtt - 1 / rps) * c * rps * (1 - strength))) * (1 - strength)
    probaility = (100 * tmp - 100 * pi_n) / tmp

    return float(ws), probaility


def prepare():
    loadfromtxt = []

    rpsfromtxt = []

    limitfromtxt = []

    file = 'load.txt'
    with open(file, 'r') as file_to_read:
        while True:
            lines = file_to_read.readline()  # 整行读取数据
            if not lines:
                break
                pass
            tmp = int(lines.strip('\n'))
            loadfromtxt.append(tmp)  # 添加新读取的数据
            pass
    pass
    filename = 'data.txt'
    with open(filename, 'r') as file_to_read:
        while True:
            lines = file_to_read.readline()  # 整行读取数据
            if not lines:
                break
                pass
            tmp_limit, tmp_rps = [float(i) for i in lines.split()]  # 将整行数据分割处理，如果分割符是空格，括号里就不用传入参数，如果是逗号， 则传入‘，'字符。
            # print(tmp_limit,tmp_rps)
            rpsfromtxt.append(tmp_rps)
            limitfromtxt.append(tmp_limit)
    pass
    print(loadfromtxt)
    print(limitfromtxt)
    print(rpsfromtxt)
    return loadfromtxt, rpsfromtxt, limitfromtxt


def main():
    with open(_YAML_FILE_NAME) as f:
        arg = yaml.load(f, Loader=yaml.FullLoader)
    loadfromtxt, rpsfromtxt, limitfromtxt = prepare()
    # rtt=getRTT(890,896,0.15,1)jjjj
    # print(rtt)
    decide(loadfromtxt, rpsfromtxt, limitfromtxt, arg)


if __name__ == '__main__':
    main()
