/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package TrafoApplication;

/**
 *
 * @author Torbjörn
 */
public class CaptureNode {
    public CaptureNode(){}
    
    private String Tag;
    
    private String RuleName;
    
    private String Data;

    public String getTag() {
        return Tag;
    }

    public void setTag(String Tag) {
        this.Tag = Tag;
    }

    public String getRuleName() {
        return RuleName;
    }

    public void setRuleName(String RuleName) {
        this.RuleName = RuleName;
    }

    public String getData() {
        return Data;
    }

    public void setData(String Data) {
        this.Data = Data;
    }
    
}
