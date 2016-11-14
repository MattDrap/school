package cz.cvut.bigdata.HBaseBulkload;

import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.KeyValue;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.RegionLocator;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.HFileOutputFormat2;
import org.apache.hadoop.hbase.util.Bytes;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.KeyValueTextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.security.UserGroupInformation;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import cz.cvut.bigdata.cli.ArgumentParser;


public class HBaseBulkload extends Configured implements Tool
{
    /**
     * The main entry of the application.
     */
    public static void main(String[] arguments) throws Exception
    {
        System.exit(ToolRunner.run(new HBaseBulkload(), arguments));
    }

    /**
     * Receives (byteOffsetOfLine, textOfLine), note we do not care about the type of the key
     * because we do not use it anyway, and emits (word, 1) for each occurrence of the word
     * in the line of text (i.e. the received value).
     */
    public static class HbaseMapper extends Mapper<Text, Text, ImmutableBytesWritable, KeyValue>
    {
          
        public void map(Text key, Text vals, Context context) throws IOException, InterruptedException
        {
        	String svals = vals.toString();
        	String[] dfval = svals.split("[,;]");
        	int mkey = Integer.parseInt(key.toString());
        	for(int i = 0; i < dfval.length; i+=2){
        		String sdoc_id = dfval[i];
        		String stf = dfval[i+1];
        		int doc_id = Integer.parseInt(sdoc_id);
        		int tf = Integer.parseInt(stf);
        		
	            byte[] word_id_bytes = Bytes.toBytes(String.valueOf(mkey));
	            ImmutableBytesWritable HKey = new ImmutableBytesWritable(word_id_bytes);
	
	            byte[] doc_bytes =  Bytes.toBytes(doc_id);
	            byte[] tf_bytes =  Bytes.toBytes(tf);
	            byte[] col_family = Bytes.toBytes("doc");
	
	            KeyValue kv = new KeyValue(word_id_bytes, col_family, doc_bytes, tf_bytes);
	            context.write(HKey, kv);
        	}
        }

    }
    
    /**
     * This is where the MapReduce job is configured and being launched.
     */
    @Override
    public int run(String[] arguments) throws Exception
    {
        ArgumentParser parser = new ArgumentParser("HBaseBulkload");

        parser.addArgument("input", true, true, "specify input directory");
        parser.addArgument("output", true, true, "specifiy output directory");
        parser.parseAndCheck(arguments);

        Path inputPath = new Path(parser.getString("input"));
        Path outputPath = new Path(parser.getString("output"));
        
        Configuration hconf = HBaseConfiguration.create();
        hconf.set("hadoop.tmp.dir", "/tmp");
        hconf.set("hadoop.security.authentication", "Kerberos");
        UserGroupInformation.setConfiguration(hconf);
        UserGroupInformation.getUGIFromTicketCache(System.getenv("KRB5CCNAME"), null);

        Job job = Job.getInstance(hconf, "HBaseIndex");
        job.setJarByClass(HBaseBulkload.class);
        job.setMapperClass(HbaseMapper.class);
        
        
        job.setMapOutputKeyClass(ImmutableBytesWritable.class);
        job.setMapOutputValueClass(KeyValue.class);

        FileInputFormat.addInputPath(job, inputPath);
        job.setInputFormatClass(KeyValueTextInputFormat.class);             
        FileOutputFormat.setOutputPath(job, outputPath);
        
        String TABLE_NAME = "bartom40:wiki_index";
        Connection connection = ConnectionFactory.createConnection(hconf);
        TableName tableName = TableName.valueOf(TABLE_NAME);
        Table hTable = connection.getTable(tableName);
        RegionLocator regionLocator = connection.getRegionLocator(tableName);
        HFileOutputFormat2.configureIncrementalLoad(job, hTable, regionLocator);
                
        FileSystem hdfs = FileSystem.get(hconf);
        if (hdfs.exists(outputPath)) hdfs.delete(outputPath, true);
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
