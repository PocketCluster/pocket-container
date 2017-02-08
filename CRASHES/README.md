# Crash Collections


### (02/07/2017)

**Insufficient Spark 2.1.0 slave node memory**

- Not enough memory in a slave node could cause it to fail. If `locale` setting is not `UTF-8`, then we'll see more of following exception.

  ```sh
  Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: 0
    at sun.nio.cs.UTF_8$Decoder.decode(UTF_8.java:441)
  ```
- When locale is right but not enough memory present, we'll see following

  ```sh
  java.lang.OutOfMemoryError: Requested array size exceeds VM limit
    at java.lang.StringCoding.encode(StringCoding.java:350)
  ```
-The insufficient memory would lead to disconnection of a spark cluster member like following.

  ```sh
  [Stage 4:=================================>                         (4 + 3) / 7]17/02/04 09:43:20 ERROR TaskSchedulerImpl: Lost executor 2 on 172.16.128.3: Remote RPC   client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
  17/02/04 09:43:20 WARN TaskSetManager: Lost task 1.1 in stage 4.0 (TID 14, 172.16.128.3, executor 2): ExecutorLostFailure (executor 2 exited caused by one of the   running tasks) Reason: Remote RPC client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
  17/02/04 09:43:20 WARN TaskSetManager: Lost task 3.1 in stage 4.0 (TID 13, 172.16.128.3, executor 2): ExecutorLostFailure (executor 2 exited caused by one of the   running tasks) Reason: Remote RPC client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
  17/02/04 09:43:20 WARN TaskSetManager: Lost task 5.1 in stage 4.0 (TID 15, 172.16.128.3, executor 2): ExecutorLostFailure (executor 2 exited caused by one of the   running tasks) Reason: Remote RPC client disassociated. Likely due to containers exceeding thresholds, or network issues. Check driver logs for WARN messages.
  [Stage 4:==================================================>        (6 + 1) / 7][I 09:43:37.896 NotebookApp] Saving file at /Untitled3.ipynb
  ```
- We cannot prevent these errors as it's hardware limitation. Adjust data size or program to fix it

> Reference

- [Crash Log : pc-node3](pc-node3.spark.logs-2017-02-07.zip)  
 