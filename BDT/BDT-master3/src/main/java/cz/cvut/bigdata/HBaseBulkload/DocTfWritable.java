package cz.cvut.bigdata.HBaseBulkload;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import org.apache.hadoop.io.Writable;

public class DocTfWritable implements Writable{

	int docid;
	int tf;
	
	public DocTfWritable(){
		docid = 0;
		tf = 0;
	}
	public DocTfWritable(int _docid, int _tf){
		docid = _docid;
		tf = _tf;
	}
	@Override
	public void readFields(DataInput arg0) throws IOException {
		docid = arg0.readInt();
		tf = arg0.readInt();
	}

	@Override
	public void write(DataOutput arg0) throws IOException {
		arg0.writeInt(docid);
		arg0.writeInt(tf);
	}
	@Override
	public String toString(){
		StringBuilder sb = new StringBuilder();
		sb.append("(");
		sb.append(Integer.toString(docid));
		sb.append(",");
		sb.append(Integer.toString(tf));
		sb.append(")");
		return sb.toString();
	}
}
