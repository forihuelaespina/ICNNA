% DIRECTORY_VIEWER
% 
% Creates a directory viewer tree control with a new
% property called SelectedDirectories. SelectedDirectories
% is a function_handle property of the tree control. When
% invoked it returns a cell array of selected directory
% paths.
%
% This file demonstrates the usage of the tree control
% together with java and nested functions.
%
%%See
%%http://xtargets.com/cms/Tutorials/Matlab-Programming/Handle-Graphics-Tree-Control-With-Nested-Functions.html

function t = directory_viewer

    root = uitreenode('c:\', 'C:\', [], false);
    t = uitree( ...
    'Root', root, ...
    'ExpandFcn', @myExpfcn );
    set(t, 'NodeSelectedCallback', @selected_cb);

    selection_hash = java.util.Hashtable;

    toolkit = java.awt.Toolkit.getDefaultToolkit;
    pin_image = toolkit.createImage([matlabroot,'/toolbox/matlab/icons/pin_icon.gif']);
    page_image = toolkit.createImage([matlabroot,'/toolbox/matlab/icons/pageicon.gif']);

    % Add a new property to the handle to return
    % the current path selection function. 
    % Note schema.prop is undocumented and you won't
    % get any help from Mathworks tech support if you
    % use it.
    prop = schema.prop( t, 'SelectedDirectories', 'mxArray');
    t.SelectedDirectories = @selections;

    % Function for the new property to return the
    % selections.
    function paths = selections(tree, paths)
        paths = {};
        enum = selection_hash.keys;
        while enum.hasMoreElements
            paths = { paths{:} char( enum.next ) };
        end
    end

    function selected_cb(tree, value)
        % Assume single selection
        nodes = tree.SelectedNodes;
        if isempty(nodes)
            return
        end
        node = nodes(1);
        path = node2path(node);
        if isdir(path)
            % Don't allow selection of directories.
            return
        end
        if isempty(selection_hash.get(path))
            selection_hash.put(path,'on');
            image = pin_image ;
        else
            selection_hash.remove(path);
            image = page_image;
        end
        node.setIcon(image);
        tree.setSelectedNode([]);
        tree.repaint;
    end

end

function path = node2path(node)
    path = node.getPath;
    for i=1:length(path);
        p{i} = char(path(i).getName);
    end
    if length(p) > 1
        path = fullfile(p{:});
    else
        path = p{1};
    end
end

function nodes = myExpfcn(tree, value)

    try
        count = 0;
        ch = dir(value);

        for i=1:length(ch)
            if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
                count = count + 1;
                if ch(i).isdir
                    iconpath = [matlabroot,'/toolbox/matlab/icons/foldericon.gif'];
                else
                    iconpath = [matlabroot,'/toolbox/matlab/icons/pageicon.gif'];
                end
                nodes(count) = uitreenode([value, ch(i).name, filesep], ...
                ch(i).name, iconpath, ~ch(i).isdir);
            end
        end
    catch
        error(['The uitree node type is not recognized. ' ... 
' You may need to define an ExpandFcn for the nodes.']);
    end

    if (count == 0)
        nodes = [];
    end
end
