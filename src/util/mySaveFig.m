function mySaveFig(hfig,filename)
%Saves a figure in different formats at once
%
% mySaveFig(hfig,filename)
%
%
%
%MATLAB has recently changed the way gcf returns its output.
%It no longer gives you a handle number.
%Since I have to deal with old (in my laptop) and new (in the desktop)
%versions of matlab, I have to check this.
%
%% Remarks
%
% Figures can have more than one container e.g. uifigures can have
% uitabgroups each one with a figure, but function print only can
% only print/export one container at a time.
%
%  In such case, this function will print each container in a separate
%   figure adding a suffix to the filename e.g.
% 
%       [filename '_subfig0001']
%
%   Note that this only apply for the picture format e.g. .png and not
%for matlab's .fig which can save all at once.
%
%% Parameters
%
% filename - String or Char[]. Output filename without extension
%   but including the output directory.
%
%
%
% @date: 29-Abr-2016
% @author: Felipe Orihuela-Espina
%
%



%% LOG
%
% 24-Mar-2021: FOE
%   - Added support to large figure using '-v7.3' (in case the default
%   '-v7' fails.
%   - Removed tag @modified.
%
% 24-Mar-2025: FOE
%   + Bug fixed: I was using gcf instead of hfig! Obviously most of the
%   the time that works because the figure to save was the one used
%   inmediately before. But gca and gcf do not work properly when a
%   figure is a uifigure instead of a figure object, so I noticed this
%   when I created the function icnna.plot.plotTimeline which uses
%   uifigure.
%   + Added support for uifigure
%
% 3-Sep-2025: FOE
%   + Bug fixed: In detecting the difference between figure and uifigure
%   only the presence of the field props.Controller was being checked
%   but not its value. Now the value (empty of regular figures) is
%   correctly checked.
%
% 5-Sep-2025: FOE
%   + Filenames can now be provided as string as well rather than
%   char[] alone.
%
% 3-Oct-2025: FOE
%   + In MATLAB R2025b the props.Controller information has been updated
%   and the method I was using to differentite between figure and uifigure
%   no longer work. However, it turns out there is a simpler way to do
%   this. Since R2018b, MATLAB has isa(hfig, 'uifigure')!!
%
% 26-Oct-2025: FOE
%  + Bug fixed: While the pacth I made on 3-Oct-25 was in the right
%  direction, but unfortunately it happens that isa(hfig, 'uifigure') had
%  also been altered in MATLAB R2025b and now a code suche as;
%     f=uifigure(...);
%     isa(hfig, 'uifigure')
%
%  ...would return 0 (false)!!
%  Consulting Copilot it tells me that this has to do with MATLAB's
%  function-class naming mismatch with the new class name being
%  'matlab.ui.Figure' yet the class creator still being uifigure.
%  Anyhow, bottom line is that the condition should be:
%     isa(hfig, 'matlab.ui.Figure')
%
% 6-Mar-2026: FOE
%  + Bug fixed: And yet another change by matlab!
%  Now asking for isa(hfig, 'matlab.ui.Figure') yields true for both
%  figures and uifigures. Now both figures and uifigure share the
%  same class; that is matlab.ui.Figure and instead their internal
%  behaviour is governed by property |Type|
%   


try
    saveas(hfig,strcat(filename,'.fig'),'fig');
catch ME
    hgsave(hfig,strcat(filename,'.fig'),'-v7.3');
end

if verLessThan('matlab','8.6')
    %print(['-f' num2str(hfig)],'-dtiff','-r300',strcat(filename,'_300dpi.tif'));
    %print(['-f' num2str(hfig)],'-dtiff','-r300',strcat(filename,'_600dpi.tif'));
    print(['-f' num2str(hfig)],'-dpng','-r600',strcat(filename,'_600dpi.png'));
    %print(['-f' num2str(hfig)],'-djpeg','-r150',strcat(filename,'_150dpi.jpg'));
    
else

    % 6-Mar-2026: FOE. Bug fixing.
    if isprop(hfig,'Type')
        flagNormalFigure = strcmp(get(gcf,'Type'),'figure');
    else
        flagNormalFigure = ~isa(hfig, 'matlab.ui.Figure');
    end

    if flagNormalFigure

        %Note that even if it is a normal figure
        %but it may still have UI-typed subcomponents e.g.
        %icnna.plot.plotTimeline

        try
            %print(hfig,'-dtiff','-r300',strcat(filename,'_300dpi.tif'));
            %print(hfig,'-dtiff','-r300',strcat(filename,'_600dpi.tif'));
            print(hfig,'-dpng','-r600',strcat(filename,'_600dpi.png'));
            %print(hfig,'-djpeg','-r150',strcat(filename,'_150dpi.jpg'));
        catch
            containers = findall(hfig, 'Type', 'uipanel', '-or', 'Type', 'uitab');
            for iChild = 1:numel(containers)
                exportgraphics(containers(iChild),...
                      strcat(filename,'_subfig',num2str(iChild,'%04d'),'_600dpi.png'),...
                        'BackgroundColor','white', 'Resolution', 600);
                    %For some reason, I can't change the option 'Padding'
            end 
        end

    else %uifigure?
        % Find all containers in the uifigure
        %containers = findall(hfig, 'Type', 'uipanel', '-or', 'Type', 'uitabgroup');
        containers = findall(hfig, 'Type', 'uipanel', '-or', 'Type', 'uitab');
        for iChild = 1:numel(containers)
            exportgraphics(containers(iChild),...
                  strcat(filename,'_subfig',num2str(iChild,'%04d'),'_600dpi.png'),...
                    'BackgroundColor','white', 'Resolution', 600);
                %For some reason, I can't change the option 'Padding'
        end 

    end

end

%close hfig
end