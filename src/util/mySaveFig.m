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
%
%% Parameters
%
% filename - Output filename without extension but including the directory
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


try
    saveas(gcf,[filename '.fig'],'fig');
catch ME
    hgsave(gcf,[filename '.fig'],'-v7.3');
end

if verLessThan('matlab','8.6')
    %print(['-f' num2str(gcf)],'-dtiff','-r300',[filename '_300dpi.tif']);
    %print(['-f' num2str(gcf)],'-dtiff','-r300',[filename '_600dpi.tif']);
    print(['-f' num2str(gcf)],'-dpng','-r300',[filename '_600dpi.png']);
    %print(['-f' num2str(gcf)],'-djpeg','-r150',[filename '_150dpi.jpg']);
    
else    
    %print(gcf,'-dtiff','-r300',[filename '_300dpi.tif']);
    %print(gcf,'-dtiff','-r300',[filename '_600dpi.tif']);
    print(gcf,'-dpng','-r300',[filename '_600dpi.png']);
    %print(gcf,'-djpeg','-r150',[filename '_150dpi.jpg']);

end

%close gcf
end