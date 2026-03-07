from pyspark.sql import SparkSession
import time

spark = SparkSession.builder \
    .appName("DistributedTest") \
    .getOrCreate()

sc = spark.sparkContext

print("Master:", sc.master)
print("Default Parallelism:", sc.defaultParallelism)

# Create distributed dataset
rdd = sc.parallelize(range(1, 10_000_000),36)

# Simulate real work
def heavy_compute(x):
    total = 0
    for i in range(100):
        total += x * i
    return total

start = time.time()

result = rdd.map(heavy_compute).sum()

end = time.time()

print("Result:", result)
print("Time Taken:", end - start)

spark.stop()
