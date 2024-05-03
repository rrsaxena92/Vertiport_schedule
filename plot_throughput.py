import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

plt.rcParams['pdf.fonttype'] = 42
plt.rcParams['ps.fonttype'] = 42

csvfolder = "E:/Digital_Twin_and_UAM/ATFM_code/Vertiport_schedule/misc/overleaf/"
figFolder = "E:/Digital_Twin_and_UAM/Figures"
# Read the CSV file

filename = "arrThroughput"
ext = ".csv"
filepath = csvfolder + filename + ext
df = pd.read_csv(filepath)

# Create a figure and axis
fig, ax = plt.subplots()

# Data for different flights
flights = df['Num_flights'].unique()
df['Throughput'] = round(df['Throughput'],2)
markers = ['o', 's', '^', 'D', 'v', 'p']

# Plot each flight separately
for flight, marker in zip(flights, markers):
    subset = df[df['Num_flights'] == flight]
    ax.plot(subset['Num_directions'], subset['Throughput'], f'{marker}-', label=f'{flight} Flights', markersize=8)

# Set labels and title
ax.set_xlabel('Number of Directions', weight='bold')
ax.set_ylabel('Throughput (VTOLs per min)', weight='bold')
ax.set_title('Set1 Arrival', weight='bold')

# Mark the maximum throughput line
maxthroughputVal = 9.4

# plt.hlines(y=5.14, label="Max throughput", linestyle="--", linewidth=2, color="grey", xmin=0.8, xmax=1.8)
plt.hlines(y=maxthroughputVal, linestyle="--",label="Max throughput", linewidth=2, color="grey", xmin=1, xmax=4)
# plt.text(1.8, 5.14, '5.14', verticalalignment='bottom', weight='bold')
plt.text(2.5, 9.4, '9.4', verticalalignment='bottom', weight='bold')

# Set xticks and yticks to available values
ax.set_xticks(df['Num_directions'].unique())
# ax.set_yticks(df['Throughput'].unique())
ax.set_yticks(np.arange(2.5,10,0.5))

# Make xticks and yticks labels bold
ax.set_xticklabels(ax.get_xticks(), weight='bold')
ax.set_yticklabels(ax.get_yticks(), weight='bold')

plt.grid()

# Add legend
ax.legend(loc='center', fontsize=10)
plt.tight_layout()
plt.savefig(figFolder + "/" + filename + ".pdf", dpi=600, transparent=True)
# Show the plot
plt.show()
