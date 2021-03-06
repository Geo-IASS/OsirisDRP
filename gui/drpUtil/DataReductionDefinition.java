package edu.ucla.astro.osiris.drp.util;

import java.beans.*;
import java.util.ArrayList;
import java.util.Iterator;

/**
 * <p>Title: OSIRIS Software Package</p>
 * <p>Description: </p>
 * <p>Copyright: Copyright (c) 2004</p>
 * <p>Company: UCLA Infrared Imaging Detector Laboratory</p>
 * @author Jason L. Weiss
 * @version 1.0
 */

public class DataReductionDefinition {

  public DataReductionDefinition() {
    logPath = "";
    reductionType = "";
    datasetInputDir = "";
    datasetName = "";
    datasetOutputDir = "";
    datasetFitsFileList = new ArrayList();
    moduleList = new ArrayList();
    updateDatasetNumber = 0;
    updateHeaderNumber = -1;
    keywordUpdateModuleList = new ArrayList();
  }
  public DataReductionDefinition(DataReductionDefinition drd) {
    logPath = drd.getLogPath();
    reductionType = drd.getReductionType();
    datasetInputDir = drd.getDatasetInputDir();
    datasetName = drd.getDatasetName();
    datasetOutputDir = drd.getDatasetOutputDir();
    datasetFitsFileList = new ArrayList();
		updateDatasetNumber = drd.getUpdateDatasetNumber();
		updateHeaderNumber = drd.getUpdateHeaderNumber();

    for (Iterator ii = drd.getDatasetFitsFileList().iterator(); ii.hasNext();) {
      datasetFitsFileList.add(ii.next());
    }
    moduleList = new ArrayList();
    for (Iterator jj = drd.getModuleList().iterator(); jj.hasNext();) {
      moduleList.add(new ReductionModule((ReductionModule)jj.next()));
    }
    keywordUpdateModuleList = new ArrayList();
    for (Iterator jj = drd.getKeywordUpdateModuleList().iterator(); jj.hasNext();) {
      keywordUpdateModuleList.add(new KeywordUpdateReductionModule((KeywordUpdateReductionModule)jj.next()));
    }
  }
  private transient PropertyChangeSupport propertyChangeListeners = new PropertyChangeSupport(this);
  private String logPath;
  private String reductionType;
  private String datasetInputDir;
  private String datasetName;
  private String datasetOutputDir;
  private ArrayList datasetFitsFileList;
  private ArrayList moduleList;
  private ArrayList keywordUpdateModuleList;
	private int updateDatasetNumber;
	private int updateHeaderNumber;
	
  public synchronized void removePropertyChangeListener(PropertyChangeListener l) {
    propertyChangeListeners.removePropertyChangeListener(l);
  }
  public synchronized void addPropertyChangeListener(PropertyChangeListener l) {
    propertyChangeListeners.addPropertyChangeListener(l);
  }

  public String getLogPath() {
    return logPath;
  }
  public void setLogPath(String logPath) {
    String  oldLogPath = this.logPath;
    this.logPath = logPath;
    propertyChangeListeners.firePropertyChange("logPath", oldLogPath, logPath);
  }
  public void setReductionType(String reductionType) {
    String  oldReductionType = this.reductionType;
    this.reductionType = reductionType;
    propertyChangeListeners.firePropertyChange("reductionType", oldReductionType, reductionType);
  }
  public String getReductionType() {
    return reductionType;
  }
  public void setDatasetInputDir(String datasetInputDir) {
    String  oldDatasetInputDir = this.datasetInputDir;
    this.datasetInputDir = datasetInputDir;
    propertyChangeListeners.firePropertyChange("datasetInputDir", oldDatasetInputDir, datasetInputDir);
  }
  public String getDatasetInputDir() {
    return datasetInputDir;
  }
  public void setDatasetName(String datasetName) {
    String  oldDatasetName = this.datasetName;
    this.datasetName = datasetName;
    propertyChangeListeners.firePropertyChange("datasetName", oldDatasetName, datasetName);
  }
  public String getDatasetName() {
    return datasetName;
  }
  public void setDatasetOutputDir(String datasetOutputDir) {
    String  oldDatasetOutputDir = this.datasetOutputDir;
    this.datasetOutputDir = datasetOutputDir;
    propertyChangeListeners.firePropertyChange("datasetOutputDir", oldDatasetOutputDir, datasetOutputDir);
  }
  public String getDatasetOutputDir() {
    return datasetOutputDir;
  }
  public void setDatasetFitsFileList(ArrayList datasetFitsFileList) {
    ArrayList  oldDatasetFitsFileList = this.datasetFitsFileList;
    propertyChangeListeners.firePropertyChange("datasetFitsFiles", oldDatasetFitsFileList, datasetFitsFileList);
    this.datasetFitsFileList = datasetFitsFileList;
  }
  public ArrayList getDatasetFitsFileList() {
    return datasetFitsFileList;
  }
  public void setModuleList(ArrayList moduleList) {
    ArrayList  oldModuleList = this.moduleList;
    this.moduleList = moduleList;
    propertyChangeListeners.firePropertyChange("moduleList", oldModuleList, moduleList);
  }
  public ArrayList getModuleList() {
    return moduleList;
  }
  public void setKeywordUpdateModuleList(ArrayList keywordUpdateModuleList) {
    ArrayList  oldKeywordUpdateModuleList = this.keywordUpdateModuleList;
    this.keywordUpdateModuleList = keywordUpdateModuleList;
    propertyChangeListeners.firePropertyChange("keywordUpdateModuleList", oldKeywordUpdateModuleList, keywordUpdateModuleList);
  }
  public ArrayList getKeywordUpdateModuleList() {
    return keywordUpdateModuleList;
  }
	public void setUpdateDatasetNumber(int updateDatasetNumber) {
		int oldUpdateDatasetNumber = this.updateDatasetNumber;
		this.updateDatasetNumber = updateDatasetNumber;
		propertyChangeListeners.firePropertyChange("updateDatasetNumber", oldUpdateDatasetNumber, updateDatasetNumber);
	}
	public int getUpdateDatasetNumber() {
		return updateDatasetNumber;
	}
	public void setUpdateHeaderNumber(int updateHeaderNumber) {
		int oldUpdateHeaderNumber = this.updateHeaderNumber;
		this.updateHeaderNumber = updateHeaderNumber;
		propertyChangeListeners.firePropertyChange("updateHeaderNumber", oldUpdateHeaderNumber, updateHeaderNumber);
	}
	public int getUpdateHeaderNumber() {
		return updateHeaderNumber;
	}
}