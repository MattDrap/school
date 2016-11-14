package cz.cvut.bigdata.wordcount;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.Normalizer;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.apache.commons.httpclient.URI;
import org.apache.commons.lang.StringUtils;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.io.WritableComparable;
import org.apache.hadoop.io.WritableComparator;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Partitioner;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.Mapper.Context;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import cz.cvut.bigdata.cli.ArgumentParser;

/**
 * WordCount Example, version 1.0
 * 
 * This is a very simple extension of basic WordCount Example implemented using
 * a new MapReduce API.
 */
public class WordCount extends Configured implements Tool
{
    /**
     * The main entry of the application.
     */
    public static void main(String[] arguments) throws Exception
    {
        System.exit(ToolRunner.run(new WordCount(), arguments));
    }

    /**
     * Sorts word keys in reversed lexicographical order.
     */
    public static class WordCountComparator extends WritableComparator
    {
        protected WordCountComparator()
        {
            super(Text.class, true);
        }
        
        @Override public int compare(WritableComparable a, WritableComparable b)
        {
            // Here we use exploit the implementation of compareTo(...) in Text.class.
            return -a.compareTo(b);
        }
    }

    /**
     * (word, count) pairs are sent to reducers based on the length of the word.
     * 
     * The maximum length of a word that will be processed by
     * the target reducer. For example, using 3 reducers the
     * word length span processed by the reducers would be:
     * reducer     lengths processed
     * -------     -----------------
     *  00000           1 -- 14
     *  00001          15 -- 29
     *  00003          30 -- OO
     */
    public static class WordLengthPartitioner extends Partitioner<Text, IntWritable>
    {
        private static final int MAXIMUM_LENGTH_SPAN = 30;
        
        @Override public int getPartition(Text key, IntWritable value, int numOfPartitions)
        {
            if (numOfPartitions == 1)
                return 0;
            
            int lengthSpan = Math.max(MAXIMUM_LENGTH_SPAN / (numOfPartitions - 1), 1);
            
            return Math.min(Math.max(0, (key.toString().length() - 1) / lengthSpan), numOfPartitions - 1);
        }
    }

    /**
     * Receives (byteOffsetOfLine, textOfLine), note we do not care about the type of the key
     * because we do not use it anyway, and emits (word, 1) for each occurrence of the word
     * in the line of text (i.e. the received value).
     */
    public static class WordCountMapper extends Mapper<Object, Text, Text, IntWritable>
    {
        private Text word = new Text();
        private Set<String> map;
        private String repaired_term;
        private boolean first;
        private IntWritable ONE = new IntWritable(1);
        
        
        @Override
        public void setup(Context context) throws IOException{
        	 
        	map = new HashSet<String>();
        	first = false;
        }
        
        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException
        {
            String[] words = value.toString().split("\\s+");
            first = true;
            
            for (String term : words)
            {
            	if(first){
            		first = false;
            		continue;
            	}
            	
            	repaired_term = term.toLowerCase();
            		
            	repaired_term = repaired_term.replaceAll("<([^>]+)>", "");
            	repaired_term = repaired_term.replaceAll("\\d+", "");
            	repaired_term = repaired_term.replaceAll("[!\"„“#$%&'()*+,./:;<=>?@\\[\\\\\\]^_`{|}~]", "");
            	repaired_term = repaired_term.replaceAll("[^a-z0-9]", "");
            	if(!StringUtils.isAsciiPrintable(repaired_term))
            		continue;
            	
            	if(repaired_term.length() < 3 || repaired_term.length() > 24){
            		continue;
            	}
            	
            	if(repaired_term.equals(""))
            		continue;
            	
            	map.add(repaired_term);
            }
            
            for (String entry : map)
        	{
        		word.set(entry);
        		context.write(word, ONE);
        	}
            
            context.write(new Text("#"), ONE);
            
            map.clear();
        }
    }

    /**
     * Receives (word, list[1, 1, 1, 1, ..., 1]) where the number of 1 corresponds to the total number
     * of times the word occurred in the input text, which is precisely the value the reducer emits along
     * with the original word as the key. 
     * 
     * NOTE: The received list may not contain only 1s if a combiner is used.
     */
    public static class WordCountReducer extends Reducer<Text, IntWritable, Text, IntWritable>
    {
    	public void reduce(Text text, Iterable<IntWritable> values, Context context) throws IOException, InterruptedException
        {
            int sum = 0;

            for (IntWritable value : values)
            {
                sum += value.get();
            }
            context.write(text, new IntWritable(sum));
        }
    }

    /**
     * This is where the MapReduce job is configured and being launched.
     */
    @Override public int run(String[] arguments) throws Exception
    {
        ArgumentParser parser = new ArgumentParser("WordCount");

        parser.addArgument("input", true, true, "specify input directory");
        parser.addArgument("output", true, true, "specify output directory");

        parser.parseAndCheck(arguments);

        Path inputPath = new Path(parser.getString("input"));
        Path outputDir = new Path(parser.getString("output"));

        // Create configuration.
        Configuration conf = getConf();
        
        // Using the following line instead of the previous 
        // would result in using the default configuration
        // settings. You would not have a change, for example,
        // to set the number of reduce tasks (to 5 in this
        // example) by specifying: -D mapred.reduce.tasks=5
        // when running the job from the console.
        //
        // Configuration conf = new Configuration(true);

        // Create job.
        Job job = Job.getInstance(conf, "WordCount");
        job.setJarByClass(WordCountMapper.class);

        // Setup MapReduce.
        job.setMapperClass(WordCountMapper.class);
        job.setReducerClass(WordCountReducer.class);

        // Make use of a combiner - in this simple case
        // it is the same as the reducer.
        //job.setCombinerClass(WordCountReducer.class);

        // Sort the output words in reversed order.
        job.setSortComparatorClass(WordCountComparator.class);
        
        // Use custom partitioner.
        job.setPartitionerClass(WordLengthPartitioner.class);

        // By default, the number of reducers is configured
        // to be 1, similarly you can set up the number of
        // reducers with the following line.
        //
        // job.setNumReduceTasks(1);

        // Specify (key, value).
        
        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(IntWritable.class);

        // Input.
        FileInputFormat.addInputPath(job, inputPath);
        job.setInputFormatClass(TextInputFormat.class);

        // Output.
        FileOutputFormat.setOutputPath(job, outputDir);
        job.setOutputFormatClass(TextOutputFormat.class);

        FileSystem hdfs = FileSystem.get(conf);

        // Delete output directory (if exists).
        if (hdfs.exists(outputDir))
            hdfs.delete(outputDir, true);

        // Execute the job.
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
