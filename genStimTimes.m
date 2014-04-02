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



%% combine all results

% combine all results into one fields
n_missing=setdiff( {'WIN','NOWIN','XXX','HASH'}, fieldnames(a.subject.stimtime) );

% if we have catch trials
if isempty(n_missing)
   allresults={a.subject.stimtime.WIN;  ...
               a.subject.stimtime.NOWIN; ...
               a.subject.stimtime.XXX;     ...
               a.subject.stimtime.HASH };

else
   allresults={a.subject.stimtime.WIN;  ...
               a.subject.stimtime.NOWIN; };
end

allresults(cellfun(@isempty,allresults))={0};
allresults=sum(cell2mat(allresults),1);
for i=1:length(allresults)
    if(allresults(i)==0)
      a.subject.stimtime(i).allresults=[];
    else
      a.subject.stimtime(i).allresults=allresults(i);
    end
end

%%%%% duration

% if we have a catch field in the stimstruct use that to id catch trials
% otherwise use the experiment design
iscatch = a.subject.experiment(:,4)==0;
if ~isempty([strfind(fieldnames(a.subject.stimtime),'Catch')])
  iscatch = ~cellfun(@isempty, {a.subject.stimtime.Catch })';
else 
  error('mat format is old! edit source if you really want to overwrite the stims that should alraedy be there!')
  %iscatch = a.subject.experiment(:,3)==0;
end

%% TODO: work with catch trial on last of block
spindur=zeros(1,size(a.subject.experiment,1));
endofblocks=[ find(diff(a.subject.experiment(:,1))>0); length(iscatch)];
if(any(iscatch( endofblocks )))
  error('catch trial on last of a block! how do I know duration')
else
  spindur(~iscatch) = [a.subject.stimtime(~iscatch).allresults] - [a.subject.stimtime(~iscatch).spin] ;
  spindur(iscatch) = [a.subject.stimtime(find(iscatch)+1).start] - [a.subject.stimtime(iscatch).spin] ;
end
%for i=1:length(spindur)
% a.subject.stimtime(i).spin_duration = spindur(i);
%end

%%%%%% output file

% foreach block
for blknum=unique(trialblklist)'
    
     % stims for just this block
     blkidxs=trialblklist==blknum;
     try
       blkstims=a.subject.stimtime(blkidxs);
     catch
       error('experiment did not finish!!?')
     end


     % foreach stimtime 
     for stim=fieldnames(blkstims)'
         stimtimes=[blkstims.(stim{1})];

         % weird matlab version issue? 2013a vs b
         if strmatch(class(stimtimes),'cell')
           stimtimes=[stimtimes{:}];
         end
         
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

     % write married spin:duration file
     filename=[ num2str(blknum,'%02d') '_spin:duration.1D'];
     fid=fopen(fullfile(folder,filename),'w');
     fprintf(fid,'%.03f:%.03f ',[[blkstims.spin];spindur(blkidxs)]);
     fclose(fid);

     % maried start:duration (where duration is from start to response ie. RT)
     filename=[ num2str(blknum,'%02d') '_start:duration.1D'];
     fid=fopen(fullfile(folder,filename),'w');
     fprintf(fid,'%.03f:%.03f ',[ [blkstims.start]; [blkstims.response] - [blkstims.start] ]);
     fclose(fid);
     
end

end

