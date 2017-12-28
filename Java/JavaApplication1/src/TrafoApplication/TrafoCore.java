/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package TrafoApplication;

import java.io.File;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreePath;
import org.jpl7.Atom;
import org.jpl7.Compound;
import org.jpl7.Query;
import org.jpl7.Term;
import org.jpl7.Variable;

/**
 *
 * @author Torbjörn
 */
public class TrafoCore {
    

    // load engine files
    public static void initializeTrafo()
    {
        String path = "";
        try{
            path = new File("C:\\Git\\Trafo\\Prolog").getCanonicalPath(); //".").getCanonicalPath();
        }
        catch(Exception ex){}
        
        Query q1 = 
            new Query( 
                "consult", 
                new Term[] {new Atom(path + "\\trafo.pl")} 
            );

        try{
            q1.open();
            q1.getSolution();
        }catch(Exception ex2){
            System.out.println(ex2.getMessage());
        }
    }
    
    public static String Construct(Term tree)
    {
        
        Variable Text = new Variable("Text");
        
        Compound callConstruct = new Compound(
            "construct",
            new Term[]{
                tree,
                Text
                });
          
        Query q2 = new Query(callConstruct);
        
        Term theText = null;
        try{
            theText = q2.oneSolution().get("Text");
        }catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        
        return theText.name();
    }
    
    public static Term CallTrawl(String target, DynamicTree tree, String source)
    {
        Variable Tree = new Variable("Tree");
        Compound callTrawl = new Compound(
            "call_trawl",
                new Term[]{
                    new Compound(":",new Term[]{
                        new Atom("target"),
                        new Atom(target)
                    }),
                    new Atom(source),
                    Tree
                }
        );
        Query q2 = new Query(callTrawl);
        
        Term treeList = null;
        try{
            treeList = q2.oneSolution().get("Tree");
            tree.clear();
            ShowTree(tree, treeList, tree.rootNode);
            tree.tree.expandPath(new TreePath(tree.rootNode.getPath()));
            
        }catch(Exception e)
        {
            System.out.println(e.getMessage());
        }
        
        return treeList;
    }
    
    private static void ShowTree(DynamicTree tree, Term inTerm, DefaultMutableTreeNode parent)
    {
        Term currTerm = inTerm;
        if(currTerm.name().equals("[|]"))
        {
            // list-part
            ShowTree(tree, currTerm.arg(1), parent);
            ShowTree(tree, currTerm.arg(2), parent);
        }
        else if(currTerm.name().equals(":"))
        {
            if(currTerm.arg(2).name().equals("::")){
                // add with rule-id, and create new tree below
                DefaultMutableTreeNode newNode;
                newNode = tree.addObject(parent,  
                        currTerm.arg(1).toString() + 
                        ":" + 
                        currTerm.arg(2).arg(1).toString() + 
                        "::");
                ShowTree(tree, currTerm.arg(2).arg(2), newNode);
            }
            else{
                // tagged terminal
                ShowNode(tree, currTerm,parent);
            }
        }
        else if(currTerm.name().equals("::")){
                // add with rule-id, and create new tree below
                DefaultMutableTreeNode newNode;
                newNode = tree.addObject(parent,  
                        currTerm.arg(1).toString() + 
                        "::");
                ShowTree(tree, currTerm.arg(2), newNode);
        }
        else if(!currTerm.name().equals("[]"))
        {
            // un-tagged terminal atoms (not empty lists)
            DefaultMutableTreeNode newNode;
            newNode = tree.addObject(parent, "'" + currTerm.name() + "'");
        }
    }
    
    private static void ShowNode(DynamicTree tree, Term nodeTerm, DefaultMutableTreeNode parent)
    {
        DefaultMutableTreeNode newNode;
                
        if(nodeTerm.arg(2).name().equals("[|]"))
        {
            newNode = tree.addObject(parent, nodeTerm.arg(1).name() + ":");
            
            ShowTree(tree, nodeTerm.arg(2),newNode);
            tree.tree.expandPath(new TreePath(newNode.getPath()));
        }
        else
        {    
            newNode = tree.addObject(parent, nodeTerm.arg(1).name() + ": " + nodeTerm.arg(2).toString());
        }
    }
    
    private static void ResetRulebase()
    {
        Query.hasSolution("dump_rules");
    }
    
    public static void LoadRulebase(String path)
    {
        ResetRulebase();
        
        Query q1 = 
            new Query( 
                "consult", 
                new Term[] {new Atom(path)} 
            );

        try{
            q1.open();
            q1.getSolution();
        }catch(Exception ex2){
            System.out.println(ex2.getMessage());
        }
    }
}
