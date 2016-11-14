package cz.cvut.bigdata.wordcount2;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

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
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.MultipleOutputs;
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
public class WordCount2 extends Configured implements Tool
{
    /**
     * The main entry of the application.
     */
    public static void main(String[] arguments) throws Exception
    {
        System.exit(ToolRunner.run(new WordCount2(), arguments));
    }

    /**
     * Sorts word keys in reversed lexicographical order.
     */
    public static class WordCount2Comparator extends WritableComparator
    {
        protected WordCount2Comparator()
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
    public static class WordLengthPartitioner extends Partitioner<IntWritable, DocTfWritable>
    {
        private static final int MAXIMUM_LENGTH_SPAN = 30;
        
        @Override public int getPartition(IntWritable key, DocTfWritable value, int numOfPartitions)
        {
            if (numOfPartitions == 1)
                return 0;
            
            int lengthSpan = Math.max(MAXIMUM_LENGTH_SPAN / (numOfPartitions - 1), 1);
            
            return Math.min(Math.max(0, (key.get() - 1) / lengthSpan), numOfPartitions - 1);
        }
    }

    /**
     * Receives (byteOffsetOfLine, textOfLine), note we do not care about the type of the key
     * because we do not use it anyway, and emits (word, 1) for each occurrence of the word
     * in the line of text (i.e. the received value).
     */
    public static class WordCount2Mapper extends Mapper<Object, Text, IntWritable, DocTfWritable>
    {
        private String repaired_term;
        private boolean first;
        private String docId;
        
        private HashMap<String, Integer> word2IntDict;
        private HashMap<Integer, Integer> wordtf;
        private MultipleOutputs<IntWritable, IntWritable> mout;
        
        @Override
        public void setup(Context context) throws IOException{
        	
        	mout = new MultipleOutputs(context);
        	
        	word2IntDict = new HashMap<String, Integer>();
        	wordtf = new HashMap<Integer, Integer>();
        	if (context.getCacheFiles() != null
                    && context.getCacheFiles().length > 0) {
	        	java.net.URI[] localPaths = context.getCacheFiles();
	        	java.net.URI path = localPaths[0];
	        	BufferedReader fis = null;
	        	try{
	        		fis = new BufferedReader(new FileReader(new File(path.getPath()).getName()));
	        		int counter = 0;
	        		for (String line = fis.readLine(); line != null; line = fis.readLine()) {
	            		String [] sarray = line.split("\\s+");
	            		
	            		word2IntDict.put(sarray[0], counter);
	            		counter++;
	        		}
	        		
	        	}catch(IOException ioe){
	        		System.err.println("No Cache file");
	        	}finally{
	        		try {
						fis.close();
					} catch (IOException e) {
						System.err.println("Failed in closing input file");
					}
	        	}
        	}
        }
        
        @Override
        public void map(Object key, Text value, Context context) throws IOException, InterruptedException
        {
            String[] words = value.toString().split("\\s+");
            first = true;
            wordtf.clear();
            int docNum = 0;
            for (String term : words)
            {
            	if(first){
            		docId = term;
            		
            		first = false;
            		continue;
            	}
            	
            	int plusval = 1;
            	
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
            	
            	//get Integer representation of word
            	Integer int_rep_term = word2IntDict.get(repaired_term);
            	if(int_rep_term != null){
            		//increase number of words in document
            		docNum++;
            		//look if integer rep. is in TF dictionary
            		Integer val = wordtf.get(int_rep_term);
            	
	            	if(val != null){
	            		wordtf.put(int_rep_term, val + plusval);
	            	}else{
	            		wordtf.put(int_rep_term, plusval);
	            	}
            	}
            }
            //Parse documentId
            int idocId = Integer.parseInt(docId);
            //Write out to another file document lengths
            mout.write("documents", new IntWritable(idocId), new IntWritable(docNum));
            for (Map.Entry<Integer, Integer> entry : wordtf.entrySet())
        	{
            	//Create Pair of (documentId, TF)
        		DocTfWritable dtf = new DocTfWritable(idocId, entry.getValue());
        		//Write out integer_word_representation - (documentId, TF)
            	context.write(new IntWritable(entry.getKey()), dtf);
        	}
        }
        
        @Override
        protected void cleanup(Context context
                ) throws IOException, InterruptedException {
        	mout.close();
        }

    }

    /**
     * Receives (word, list[1, 1, 1, 1, ..., 1]) where the number of 1 corresponds to the total number
     * of times the word occurred in the input text, which is precisely the value the reducer emits along
     * with the original word as the key. 
     * 
     * NOTE: The received list may not contain only 1s if a combiner is used.
     */
    public static class WordCount2Reducer extends Reducer<IntWritable, DocTfWritable, IntWritable, Text>
    {	
    	public void reduce(IntWritable word, Iterable<DocTfWritable> values, Context context) throws IOException, InterruptedException
        {
    		/*ArrayWritable arr = new ArrayWritable(DocTfWritable.class);
    		int size = Iterables.size(values);
    		DocTfWritable [] subarr = new DocTfWritable[size];
    		int i = 0;
    		
    		for(Iterator<DocTfWritable> iterator = values.iterator(); iterator.hasNext(); iterator.next()){
    			subarr[i] = iterator.getClass();
    		}*/
    		
    		StringBuilder sb = new StringBuilder();
    		for(DocTfWritable df : values){
    			sb.append(df.toString());
    			sb.append(';');
    		}
    		sb = sb.deleteCharAt(sb.length() - 1);
            context.write(word, new Text(sb.toString()));
            
        }
    }

    /**
     * This is where the MapReduce job is configured and being launched.
     */
    @Override public int run(String[] arguments) throws Exception
    {
        ArgumentParser parser = new ArgumentParser("WordCount2");

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
        Job job = Job.getInstance(conf, "WordCount2");
        job.setJarByClass(WordCount2Mapper.class);

        job.addCacheFile(new Path("bartom40-wiki/sorted2").toUri());
        // Setup MapReduce.
        job.setMapperClass(WordCount2Mapper.class);
        job.setReducerClass(WordCount2Reducer.class);

        // Make use of a combiner - in this simple case
        // it is the same as the reducer.
        //job.setCombinerClass(WordCountReducer.class);

        // Sort the output words in reversed order.
        //job.setSortComparatorClass(WordCount2Comparator.class);
        
        // Use custom partitioner.
        //job.setPartitionerClass(WordLengthPartitioner.class);

        // By default, the number of reducers is configured
        // to be 1, similarly you can set up the number of
        // reducers with the following line.
        //
        // job.setNumReduceTasks(1);

        // Specify (key, value).
        job.setMapOutputKeyClass(IntWritable.class);
        job.setMapOutputValueClass(DocTfWritable.class);
        
        job.setOutputKeyClass(IntWritable.class);
        job.setOutputValueClass(Text.class);

        // Input.
        FileInputFormat.addInputPath(job, inputPath);
        job.setInputFormatClass(TextInputFormat.class);

        // Output.
        FileOutputFormat.setOutputPath(job, outputDir);
        job.setOutputFormatClass(TextOutputFormat.class);

        FileSystem hdfs = FileSystem.get(conf);
        
        MultipleOutputs.addNamedOutput(job, "documents", TextOutputFormat.class, IntWritable.class, IntWritable.class);
        
        // Delete output directory (if exists).
        if (hdfs.exists(outputDir))
            hdfs.delete(outputDir, true);

        // Execute the job.
        return job.waitForCompletion(true) ? 0 : 1;
    }
}
