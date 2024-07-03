classdef OPreader

    properties (SetAccess = private)

        folder
        

    end


    methods

        function obj = OPreader(inputDir)

            %Parse directory to get number of images, rows, cols, etc.
            if nargin == 0
                error('Please specify directory of images.')
            else

                if ~exist(inputDir, 'dir')
                    error('OPreader:DirectoryDoesNotExist', ...
                        'Directory %s does not exist.', inputDir)
                end

                files



            end





        end
    

    end


end