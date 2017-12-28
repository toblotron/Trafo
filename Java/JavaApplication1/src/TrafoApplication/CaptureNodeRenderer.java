/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package TrafoApplication;

import java.awt.Color;
import java.awt.Component;
import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTree;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeCellRenderer;
import javax.swing.tree.TreeCellRenderer;

/**
 *
 * @author Torbjörn
 */
public class CaptureNodeRenderer implements TreeCellRenderer {
  JLabel tagLabel = new JLabel(" ");

  JLabel ruleNameLabel = new JLabel(" ");

  JLabel dataLabel = new JLabel(" ");
  
  JPanel renderer = new JPanel();

  DefaultTreeCellRenderer defaultRenderer = new DefaultTreeCellRenderer();

  Color backgroundSelectionColor;

  Color backgroundNonSelectionColor;

  public CaptureNodeRenderer() {
    tagLabel.setForeground(Color.BLUE);
    renderer.add(tagLabel);
    
    ruleNameLabel.setBackground(Color.LIGHT_GRAY);
    renderer.add(ruleNameLabel);
    
    dataLabel.setForeground(Color.BLUE);
    renderer.add(dataLabel);
    
    
    renderer.setBorder(BorderFactory.createLineBorder(Color.BLACK));
    backgroundSelectionColor = defaultRenderer.getBackgroundSelectionColor();
    backgroundNonSelectionColor = defaultRenderer.getBackgroundNonSelectionColor();
  }

  public Component getTreeCellRendererComponent(JTree tree, Object value, boolean selected,
      boolean expanded, boolean leaf, int row, boolean hasFocus) {
    Component returnValue = null;
    if ((value != null) && (value instanceof DefaultMutableTreeNode)) {
      Object userObject = ((DefaultMutableTreeNode) value).getUserObject();
      if (userObject instanceof CaptureNode) {
        CaptureNode e = (CaptureNode) userObject;
        tagLabel.setText(e.getTag());
        ruleNameLabel.setText(e.getRuleName());
        dataLabel.setText("" + e.getData());
        if (selected) {
          renderer.setBackground(backgroundSelectionColor);
        } else {
          renderer.setBackground(backgroundNonSelectionColor);
        }
        renderer.setEnabled(tree.isEnabled());
        returnValue = renderer;
      }
    }
    if (returnValue == null) {
      returnValue = defaultRenderer.getTreeCellRendererComponent(tree, value, selected, expanded,
          leaf, row, hasFocus);
    }
    return returnValue;
  }
}
