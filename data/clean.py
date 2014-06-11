import util
import json
import pprint as pp
import numpy as np

def clean_popularity_data(fn_pickle, fn_json):
    data = util.unpickle_data(fn_pickle)
    subreddits = [v for k,v in data.iteritems()]
    res = {}
    for info in subreddits:
        name = info["display_name"]
        res[name] = {"display_name":name,
                     "subscribers":info["subscribers"],
                     "views":{"hour":None,
                              "day":None,
                              "month":None},
                     "top":{"votes":{"mean":None,"max":None}, #ups+downs
                            "score":{"mean":None,"max":None}, #ups-downs               
                            "ups":{"mean":None,"max":None},                         
                            "downs":{"mean":None,"max":None}}}
                         
        traffic = info["traffic"]
        if traffic:
            for timescale in ["hour", "day", "month"]:
                views = [x[2] for x in traffic[timescale] if x[2] > 0]
                res[name]["views"][timescale] = np.mean(views)

        metrics = ["votes","score","ups","downs"]
        d = [[] for x in xrange(len(metrics))]
        top = info["top"]
        if top:
            for post in top:
                d[0].append(post["data"]["score"])
                d[1].append(post["data"]["ups"])
                d[2].append(post["data"]["downs"])
                d[3].append(post["data"]["ups"]+post["data"]["downs"])
            for i, metric in enumerate(metrics):
                res[name]["top"][metric]["mean"]=np.mean(d[i])
                res[name]["top"][metric]["max"]=max(d[i])
    with open(fn_json, "wb") as fp:
        json.dump(res,fp)
        fp.close()




       
