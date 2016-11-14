package cz.cvut.bdt;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.StringUtils;
import org.apache.zookeeper.Environment;
import org.hbase.async.Config;
import org.hbase.async.GetRequest;
import org.hbase.async.HBaseClient;
import org.hbase.async.KeyValue;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

final class Example {

	static final String configFile = "asynchbase.properties";

	public static Map<String, Integer> createDictionary(String pathname) throws URISyntaxException{
		Map<String, Integer> dictionary = new HashMap<String, Integer>();
		URI path = new URI(pathname);
		BufferedReader fis = null;
    	try{
    		fis = new BufferedReader(new FileReader(new File(path.getPath()).getName()));
    		int counter = 0;
    		for (String line = fis.readLine(); line != null; line = fis.readLine()) {
        		String [] sarray = line.split("\\s+");
        		dictionary.put(sarray[0], counter);
        		counter++;
    		}
    		return dictionary;
    		
    	}catch(IOException ioe){
    		System.err.println("No Cache file");
    	}finally{
    		try {
				fis.close();
			} catch (IOException e) {
				System.err.println("Failed in closing input file");
			}
    	}
		return dictionary;
	}
	public static Map<Integer, Integer> createDF(String pathname, Map<String, Integer> map) throws URISyntaxException{
		Map<Integer, Integer> dictionary = new HashMap<Integer, Integer>();
		URI path = new URI(pathname);
		BufferedReader fis = null;
    	try{
    		fis = new BufferedReader(new FileReader(new File(path.getPath()).getName()));
    		for (String line = fis.readLine(); line != null; line = fis.readLine()) {
        		String [] sarray = line.split("\\s+");
        		int df = Integer.parseInt(sarray[1]);
        		dictionary.put(map.get(sarray[0]), df);
    		}
    		return dictionary;
    		
    	}catch(IOException ioe){
    		System.err.println("No Cache file");
    	}finally{
    		try {
				fis.close();
			} catch (IOException e) {
				System.err.println("Failed in closing input file");
			}
    	}
		return dictionary;
	}
	
	public static Map<Integer, Integer> createDoc2Len(String pathname) throws URISyntaxException{
		Map<Integer, Integer> doc2len = new HashMap<Integer, Integer>();
		URI path = new URI(pathname);
		BufferedReader fis = null;
		
		double summation = 0;
    	try{
    		File dir = new File(path.getPath());
    		if(dir.isDirectory()){
    			for(File file : dir.listFiles()){
		    		fis = new BufferedReader(new FileReader(file.getPath()));
		    		for (String line = fis.readLine(); line != null; line = fis.readLine()) {
		        		String [] sarray = line.split("\\s+");
		        		int doc_id = Integer.parseInt(sarray[0]);
		        		int len = Integer.parseInt(sarray[1]);
		        		summation += len;
		        		doc2len.put(doc_id, len);
		    		}
		    		fis.close();
    			}
    		}else{
    			fis = new BufferedReader(new FileReader(dir.getName()));
	    		for (String line = fis.readLine(); line != null; line = fis.readLine()) {
	        		String [] sarray = line.split("\\s+");
	        		int doc_id = Integer.parseInt(sarray[0]);
	        		int len = Integer.parseInt(sarray[1]);
	        		summation += len;
	        		doc2len.put(doc_id, len);
	    		}
    		}
    		doc2len.put(-1, (int)(summation/doc2len.size()));
    		return doc2len;
    		
    	}catch(IOException ioe){
    		System.err.println("No Cache file");
    	}finally{
    		try {
				fis.close();
			} catch (IOException e) {
				System.err.println("Failed in closing input file");
			}
    	}
		return doc2len;
	}
	public static ArrayList<Integer> cleanQuery(String query, Map<String, Integer> map){
		ArrayList<Integer> allowed = new ArrayList<Integer>();
		String[] words = query.toString().split("\\s+");
		for(String term : words){
			String repaired_term = term.toLowerCase();
			
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
	    	
	    	Integer num = map.get(repaired_term);
	    	if(num != null){
	    		allowed.add(num);
	    	}
		}
		return allowed;
	}
	
	public static void main(final String[] args) throws Exception {
		
		//-- PARSE ARGUMENTS --// 
		System.setProperty(org.slf4j.impl.SimpleLogger.DEFAULT_LOG_LEVEL_KEY, "TRACE");
		Logger logger = LoggerFactory.getLogger(Example.class);
		
		ArgumentParser parser = new ArgumentParser("HBaseClient");
		parser.addArgument("async_conf", true, true, "specify path to asynchbase.properties");
		parser.addArgument("auth_conf", true, true, "specify path to java.security.auth.login.config");
		parser.addArgument("max", true, false, "max output");
		parser.addArgument("dictionary", true, true, "input path to dictionary");
		parser.addArgument("doc2len", true, true, "intput path to document lengths");
		parser.addArgument("query", true, true, "specify your query");
		parser.parseAndCheck(args);
		String async_conf = parser.getString("async_conf");
		String auth_conf = parser.getString("auth_conf");
		Integer max = parser.getInt("max");
		if(max == null)
			max = 5;
		String table = "bartom40:wiki_index";
		logger.debug(table);
		
		String dict_path = parser.getString("dictionary");
		String doc_path = parser.getString("doc2len");
		String query = parser.getString("query");
		
		//-- SET java.security.auth.login.config --//
		System.setProperty("java.security.auth.login.config", auth_conf);
		//-- LOAD DATA FROM HBASE --// 
		Config config = new Config(async_conf);
		HBaseClient client = new HBaseClient(config);
		
		int DOCMAXN = 2322105;
		double k1 = 1.5;
		double b = 0.75;
		Map<String, Integer> dict = createDictionary(dict_path);
		logger.debug(String.valueOf(dict.size()));
		Map<Integer, Integer> DF = createDF(dict_path, dict);
		logger.debug(String.valueOf(DF.size()));
		Map<Integer, Integer> doc2len = createDoc2Len(doc_path);
		logger.debug(String.valueOf(doc2len.size()));
		ArrayList<Integer> query_words = cleanQuery(query, dict);
		logger.debug(String.valueOf(query_words.size()));
		
		Map<Integer, Double> doc_scores = new HashMap<Integer, Double>();
		int avgD = doc2len.get(-1);
		for(Integer i : query_words){
			int df = DF.get(i);	
			double idf = Math.log( (DOCMAXN -df + 0.5)/(df + 0.5) );
			GetRequest get = new GetRequest(table, String.valueOf(i).getBytes());
			try {
				ArrayList<KeyValue> result = client.get(get).joinUninterruptibly();
				
				for (KeyValue res : result) {
					
					//load doc_id  (string)
					ByteBuffer bb2 = ByteBuffer.wrap(res.qualifier());	//	StandardCharsets.UTF_8
					int doc_id = bb2.getInt();
					
					// load tf (integer)
					ByteBuffer bb = ByteBuffer.wrap(res.value());
					int tf = bb.getInt();
					
					int lenD = doc2len.get(doc_id);
					int freq = tf;
					double bm25 = freq * (k1 + 1) / (freq + k1 * (1 - b + b* lenD/avgD));
					Double mscore = doc_scores.get(doc_id);
					if(mscore != null){
						doc_scores.put(doc_id, mscore + idf*bm25);
					}else{
						doc_scores.put(doc_id, idf*bm25);
					}
					
				}
	
			} catch (Exception e) {
				logger.debug("Get failed:");
				logger.debug(e.getMessage());
				e.printStackTrace();
			}
		
	   }
		client.shutdown();
		List<Map.Entry<Integer, Double>> list = new LinkedList<Map.Entry<Integer, Double>>(doc_scores.entrySet());

			// Sort list with comparator, to compare the Map values
		Collections.sort(list, new Comparator<Map.Entry<Integer, Double>>() {
				public int compare(Map.Entry<Integer, Double> o1,
	                                           Map.Entry<Integer, Double> o2) {
					return (o2.getValue()).compareTo(o1.getValue());
				}
			});
		for (int i = 0; i < max; i++){
			System.out.println(String.valueOf( list.get(i).getKey()) + ":" + String.valueOf(list.get(i).getValue()));
			
		} 
	}

}