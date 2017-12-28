/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package TrafoApplication;

import java.util.ArrayList;

/**
 *
 * @author Torbjörn
 */
public class WorkbenchManager {
    private ArrayList<TrafoWorkbench> Work = new ArrayList<TrafoWorkbench>();

    public ArrayList<TrafoWorkbench> getWork() {
        return Work;
    }

    public void setWork(ArrayList<TrafoWorkbench> Work) {
        this.Work = Work;
    }
    
}
