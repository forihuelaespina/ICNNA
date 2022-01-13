function nodes = myExperimentExpandFcn(tree,value)
%GUI/MYEXPERIMENTEXPANDFCN A expand function for a uitree holding a experiment 
%
    try
        count = 0;
        if (~isempty(value))
            nSubjects=getNSubjects(e);
            for ii=1:nSubjects
                count = count + 1;
                s=subject(getSubject(e,ii));
                nodes(count)=uitreenode('Subject', get(s,'tag'), iconpath, false);
            end
        end
%         ch = dir(value);
% 
%         for i=1:length(ch)
%             if (any(strcmp(ch(i).name, {'.', '..', ''})) == 0)
%                 count = count + 1;
%                 if ch(i).isdir
%                     iconpath = [matlabroot,'/toolbox/matlab/icons/foldericon.gif'];
%                 else
%                     iconpath = [matlabroot,'/toolbox/matlab/icons/pageicon.gif'];
%                 end
%                 nodes(count) = uitreenode([value, ch(i).name, filesep], ...
%                 ch(i).name, iconpath, ~ch(i).isdir);
%             end
%         end
    catch
        error(['The uitree node type is not recognized. ' ... 
                ' You may need to define an ExpandFcn for the nodes.']);
    end

    if (count == 0)
        nodes = [];
    end
    tree.repaint;
end


