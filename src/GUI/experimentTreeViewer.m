function tree=experimentTreeViewer(hObject)
%Creates a user interface control for displaying experiment objects as
%trees and allow selection of elements.
%
%
%Parameters:
%===========
%
% e - An experiment
%
%
% Copyright 2008
% @date: 20-Apr-2008
% @author Felipe Orihuela-Espina
%

handles=guidata(hObject);
if (isempty(handles))
    e=[];
else
    e=handles.currentDoc.data;
end

%%See
%%http://xtargets.com/cms/Tutorials/Matlab-Programming/Handle-Graphics-Tree-Control-With-Nested-Functions.html
%%.
%%uitreenode(arg1,arg2, arg3, arg4)
%%arg1 - The object ??? . I think this is passed as parameter 'value'
%%........to the expand function
%%arg2 - Label/String to be displayed as the node
%%arg3 - Icon to eb displayed preceding the node string
%%arg4 - Indicates whether the node "isLeaf".
%%.
if (isempty(e))
    root = uitreenode([], 'Experiment', [] ,false);
else
    root = uitreenode(e, get(e,'tag'), [] ,false);
end
%set(root,'ExpandFcn', {@myExperimentExpandFcn} );
tree = uitree(hObject,'Root', root, ...
    'ExpandFcn', {@myExperimentExpandFcn}, ...
    'Units', 'normalized',...
    'Position',[0.3 0.3 0.7 0.7]);
set(tree,'NodeSelectedCallback', {@nodeSelected_Callback});

toolkit = java.awt.Toolkit.getDefaultToolkit;
pin_image = toolkit.createImage([matlabroot,'/toolbox/matlab/icons/pin_icon.gif']);
%page_image = toolkit.createImage([matlabroot,'/toolbox/matlab/icons/pageicon.gif']);



% Add a new property to the handle to return
% the current path selection function.
% Note schema.prop is undocumented and you won't
% get any help from Mathworks tech support if you
% use it.
selection_hash = java.util.Hashtable;
prop = schema.prop( tree, 'SelectedItems', 'mxArray');
tree.SelectedItems = @getSelections;

% Function for the new property 'SelectedItems' to return the
% selections.
function items = getSelections(tree, items)
    items = {};
    enum = selection_hash.keys;
    while enum.hasMoreElements
        enum.next
        items = { items{:}, enum.next };
    end
end



%% nodeSelected_Callback
function nodeSelected_Callback(tree,value)
% tree - The node selected ??
% value - A node selected event
    % Assume single selection
    nodes = tree.SelectedNodes;
    if isempty(nodes)
        return
    end
    node = nodes(1);
    node.setIcon(pin_image);
    tree.setSelectedNode([]);
    tree.repaint;
end






%%%========================================================
%%% USING JAVA
%%%========================================================
% %The code creates an instance of DefaultMutableTreeNode to
% %serve as the root node for the tree. It then creates the
% %rest of the nodes in the tree. After that, it creates
% %the tree, specifying the root node as an argument to the
% %JTree constructor.
% %%%tree = javax.swing.JTree;
% top = javax.swing.tree.DefaultMutableTreeNode;
% createNodes(top);
% tree = javax.swing.JTree(top);

% 
% 
% 
% %% createNodes
% function createNodes(top)
% % top - A DefaultMutableTreeNode
% 
% e
% 
% 
% %     category = javax.swing.tree.DefaultMutableTreeNode('Books for Java Programmers');
% %     book = javax.swing.tree.DefaultMutableTreeNode;
% %     
% %     top.add(category);
% %     
% %     %%original Tutorial
% %     book = new DefaultMutableTreeNode(new BookInfo
% %         ("The Java Tutorial: A Short Course on the Basics",
% %         "tutorial.html"));
% %     category.add(book);
% %     
% %     %%Tutorial Continued
% %     book = new DefaultMutableTreeNode(new BookInfo
% %         ("The Java Tutorial Continued: The Rest of the JDK",
% %         "tutorialcont.html"));
% %     category.add(book);
% %     
% %     %%JFC Swing Tutorial
% %     book = new DefaultMutableTreeNode(new BookInfo
% %         ('The JFC Swing Tutorial: A Guide to Constructing GUIs',
% %         'swingtutorial.html'));
% %     category.add(book);
% % 
% %     %%...add more books for programmers...
% % 
% %     category = new DefaultMutableTreeNode('Books for Java Implementers');
% %     top.add(category);
% % 
% %     %%VM
% %     book = new DefaultMutableTreeNode(new BookInfo
% %         ('The Java Virtual Machine Specification',
% %          'vm.html'));
% %     category.add(book);
% % 
% %     %%Language Spec
% %     book = new DefaultMutableTreeNode(new BookInfo
% %         ('The Java Language Specification',
% %          'jls.html'));
% %     category.add(book);
% %     end
% % 
% 
% end

end %experiment Tree Viewer %Necessary because nested functions are being used.






