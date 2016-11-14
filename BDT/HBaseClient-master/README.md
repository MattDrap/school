# Simple HBASE client in Metacentrum 

### How to run the client

STEP 1: Build the application with dependencies using Maven

```Shell
mvn clean compile assembly:single
```

STEP 2: Copy JAR file,jaas.conf and asynchbase.properties to HADOR

STEP 3: Edit jaas.conf (replace hawking with yout login name):

STEP 4: Run the client

```Shell
java -jar HBaseClient-jar-with-dependencies.jar -auth_conf PATH/TO/jaas.conf -async_conf PATH/TO/asynchbase.properties -table "LOGIN:TABLENAME" -row_key ROW_KEY
```


