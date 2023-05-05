import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt

folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/Results/Experiment_set_2"
filename = "Vertiport_Direction.csv"

vertdf_dir = pd.read_csv(folder + "/" + filename)
meandf_dir = pd.DataFrame(columns=["NumFlights", "Directions", "delay"])


k = 0
for i in vertdf_dir["num Flights"].unique():
    for j in vertdf_dir.Directions.unique():
        meandf_dir.loc[k,"NumFlights"] = i
        meandf_dir.loc[k,"Directions"] = j
        meandf_dir.loc[k,"delay"] = vertdf_dir[(vertdf_dir["num Flights"]==i) & (vertdf_dir.Directions==j)].mean().Delay
        k += 1
# fig, ax = plt.subplots()


#sns.relplot(data=vertdf_dir, x="num Flights", y="Delay", hue="Directions", kind="line", palette="Set2")
# sns.relplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="line", palette="Set2")


# sns.catplot(data=vertdf_dir, x="num Flights", y="Delay", hue="Directions", kind="box")
# g = sns.catplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="box", showmeans=True, meanprops={"marker": ".",
#                        "markeredgecolor": "black",
#                        "markersize": "5"})
# h = sns.relplot(data=vertdf_dir, x="Directions", y="Delay", hue="num Flights", kind="line", palette="Set2", facet_kws=g)
# plt.plot(meandf_dir.Directions.unique(),meandf_dir[meandf_dir.NumFlights==20].delay)
# plt.ylim([0,140])

# sns.relplot(data=meandf_dir, x="Directions", y="delay", hue="NumFlights", kind="line", palette="Set2", ax=ax2)
folder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/Vertiport_schedule/Results/Common_segment"
filename = "verti_common.csv"
vertdf_common = pd.read_csv(folder + "/" + filename)

meandf_ratio = pd.DataFrame(columns=["NumFlights", "Directions", "Delay"])


k = 0
for i in vertdf_common["NumFlights"].unique():
    for j in vertdf_common.Ratio.unique():
        meandf_ratio.loc[k,"NumFlights"] = i
        meandf_ratio.loc[k,"Ratio"] = j
        meandf_ratio.loc[k,"Delay"] = vertdf_common[(vertdf_common["NumFlights"]==i) & (vertdf_common.Ratio==j)].mean().Delay
        k += 1

# sns.catplot(data=vertdf_common, x="NumFlights", y="Delay", hue="Ratio", kind="box")
# ax = sns.catplot(data=vertdf_common, x="Ratio", y="Delay", hue="NumFlights", kind="box", showmeans=True, meanprops={"marker": ".",
#                        "markeredgecolor": "black",
#                        "markersize": "5"})
# sns.move_legend(ax, "center")
# plot a line plot with markers for the means
# sns.lineplot(data=meandf_ratio, x="Ratio", y="Delay", hue="NumFlights", marker='o', ax=ax.ax, legend=False)

# sns.relplot(data=vertdf_common, x="NumFlights", y="Delay", hue="Ratio", kind="line", palette="Set2")
# sns.relplot(data=vertdf_common, x="Ratio", y="Delay", hue="NumFlights", kind="line", palette="Set2")
# df_dir=pd.DataFrame(columns=["num Flights","fix", "Delay"])
#
# df_dir["num Flights"] = vertdf_dir["num Flights"]
# df_dir["fix"] = vertdf_dir["Directions"]
# df_dir["Delay"] = vertdf_dir["Delay"]
#
# ax = sns.catplot(data=df_dir, x="fix", y="Delay", hue="num Flights", kind="box", showmeans=True)
#
# sns.lineplot(data=meandf_ratio, x="Ratio", y="Delay", hue="NumFlights", marker='o', ax=ax.ax, legend=False)


''' A try to put catplot and lineplot in same graph'''
# g = sns.FacetGrid(vertdf_dir)
# g.map_dataframe(sns.boxplot, x="num Flights", y="Delay", hue="Directions")
# g.map_dataframe(sns.lineplot,x="num Flights", y="Delay", hue="Directions")

""" Histogram for flights"""
vertdf20 = vertdf_dir[vertdf_dir["num Flights"] == 20]
# sns.histplot(data=vertdf20, x="Delay", hue="Directions", palette="Set2", multiple="stack")
# plt.title("All")
fig, axes = plt.subplots(nrows=2, ncols=2, figsize=(10, 6))
for i in vertdf20.Directions.unique():
    vertDirdf20 = vertdf20[vertdf20["Directions"]==i]
    plt.figure()
    hist =  sns.histplot(data=vertDirdf20, x="Delay", binwidth=10, binrange=[min(vertdf20["Delay"]), max(vertdf20["Delay"])], ax=axes[i])
    hist.set_yticks(range(0,10))
    plt.title("Directions " + str(i))


plt.tight_layout()
plt.show()