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
public class TrafoWorkbench {
    private String Title;
    private String Command;
    private String RuleFilePath;
    private String SourceFilePath;

    public String getTitle() {
        return Title;
    }

    public void setTitle(String Title) {
        this.Title = Title;
    }

    public String getCommand() {
        return Command;
    }

    public void setCommand(String Command) {
        this.Command = Command;
    }

    public String getRuleFilePath() {
        return RuleFilePath;
    }

    public void setRuleFilePath(String RuleFilePath) {
        this.RuleFilePath = RuleFilePath;
    }

    public String getSourceFilePath() {
        return SourceFilePath;
    }

    public void setSourceFilePath(String SourceFilePath) {
        this.SourceFilePath = SourceFilePath;
    }
   
}
