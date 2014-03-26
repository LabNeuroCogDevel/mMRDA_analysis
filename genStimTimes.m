function genStimTimes(matfile)
%GENSTIMTIMES create stimtimes
%   generate basic stimtimes from mat file output of the slottask
%   1) break up timeing vector into blocks
%   2) save each stim file in a subject_run directory
a=load(matfile);
%trialblklist=a.subject.experiment(:,a.subject.expercol2idx('Block'));
trialblklist=a.subject.experiment(:,1);

RT=[a.subject.stimtime.response] - [a.subject.stimtime.start];


% where to save
folder=fullfile('stimtimes', ...
       [ num2str(a.subject.subj_id) '_' num2str(a.subject.run_date) ] );
if(~exist(folder,'dir')), mkdir(folder), end

% combine all results into one fields
allresults ={a.subject.stimtime.NOWIN;  ...
             a.subject.stimtime.NOWIN;   ...
             a.subject.stimtime.XXX;     ...
             a.subject.stimtime.HASH };
allresults(cellfun(@isempty,allresults))={0};
allresults=sum(cell2mat(allresults),1);
for i=1:length(allresults)
    if(allresults(i)==0)
      a.subject.stimtime(i).allresults=[];
    else
      a.subject.stimtime(i).allresults=allresults(i);
    end
end

% foreach block
for blknum=unique(trialblklist)'
    
     blkidxs=trialblklist==blknum;
     % foreach stimtime 
     for stim=fieldnames(a.subject.stimtime)'
         stimtimes=[a.subject.stimtime(blkidxs).(stim{1})];
         
         if(isempty(stimtimes))
             continue;
             % ie. XXX or HASH on Reward block
             %     WIN or NOWIN on Control block
         end
         
         % change the name so we can do WIN* or NOWIN* in 3dDeconvolve
         if(strcmp(stim{1},'XXX'))
             stim{1}='NOWINcontrol';
         elseif(strcmp(stim{1},'HASH'))
             stim{1}='WINcontrol';
         end
         
         filename=[ num2str(blknum,'%02d') '_' stim{1} '.1D'];
         fid=fopen(fullfile(folder,filename),'w');
         
         
         fprintf(fid,'%.03f ',stimtimes);
         
         fclose(fid);
         
     end
     
end

end

