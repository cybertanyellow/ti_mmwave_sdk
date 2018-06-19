szCPLX16 = 4; %size of complex16 type
szUINT16 = 2; %size of uint16_t
szL3 = 655360; %L3 memory size
szL2 = 49152;  %L2 memory static heap size
szL1 = 16384; %L1 heap size
testNum = 1;
AFFT = 64; %Azimuth FFT size
MAX_DET_OBJ = 100; %Maximum number of detected objects 
MAX_DET_OBJECTS_RAW = 2048;
szDetObj = 12; %Size in bytes of one detected object data
szObjRaw = 6; %sizeof (MmwDemo_objRaw_t)
rng(987654321);

config = zeros(94*2,24);

fprintf('Test# Ntx Nrx RFFT DFFT L3(kB) L2(kB) L1(kB)   BPM\n');
for BPM = [0 1]
    for Ntx = [1 2] %Number of Tx antennas
        if((BPM == 0) || ((BPM == 1) && (Ntx == 2)))
            for Nrx = [1 2 4] %Number of Rx antennas
                if Nrx >= Ntx 
                    for RFFT = [64 128 256 512 1024] %Range FFT size
                        for DFFT = [16 32 64 128 256] %Doppler FFT size
                            % Required space in L3 memory
                            L3 = Ntx * Nrx * RFFT * DFFT * szCPLX16 + ... %radarCube
                                 RFFT * DFFT * szUINT16 + ... %detMatrix
                                 Ntx * Nrx * RFFT * szCPLX16 + ... %azimuthStaticHeatMap
					        	 Ntx * Nrx * RFFT * szCPLX16; %ADCdataBuf
                                 
                            %Required space in L2 memory.
                            sumAbsRange = RFFT*4;
                            cfarDetObjIndexBuf = max(RFFT,DFFT)*2;
                            fftOut1D = 2*Nrx*RFFT*4;
                            L2 = ...
                                max(fftOut1D, max(cfarDetObjIndexBuf,sumAbsRange)) + ...
                                32*2*4*8 + ... %dcRangeSigMean 
                                RFFT/2*2 + ... %window1D                                
                                DFFT*8 + ... %twiddle32x32_2D
                                DFFT/2*4 + ... %window2D
                                DFFT*2*2 + ... %azimuthModCoefs
                                2*RFFT*2 + ... %twiddle16x16_1D
                                MAX_DET_OBJ*szDetObj + ... %detObj2D
                                MAX_DET_OBJ*1 + ... %detObj2dAzimIdx
                                AFFT*8 ; %azimuthTwiddle32x32
                                
                            %Required space in L1 memory.
                            adcDataIn = 2*RFFT*4;    
                            dstPingPong = 2*DFFT*4;
                            fftOut2D = DFFT*8*2;
                            windowingBuf2D = DFFT*8;
                            log2Abs = DFFT*2;
                            sumAbs = 2*2*DFFT;
                            detObj2DRaw = szObjRaw*MAX_DET_OBJECTS_RAW;
                            azimuthIn = (AFFT + Ntx*Nrx)*8;
                            azimuthOut = 2*8*AFFT;
                            azimuthMagSqr = 2*8*AFFT; 
                            
                            % L1 = max( adcDataIn,...
                            %          (dstPingPong + fftOut2D + max(windowingBuf2D,log2Abs) + sumAbs),...
                            %          detObj2DRaw,...
                            %          (dstPingPong + azimuthIn + azimuthOut + azimuthMagSqr));
                            %
                            D1 = adcDataIn;
                            D2 = (dstPingPong + fftOut2D + max(windowingBuf2D,log2Abs) + sumAbs);
                            CFAR = detObj2DRaw;
                            D3 = (dstPingPong + azimuthIn + azimuthOut + azimuthMagSqr);                            
                            L1 = max(D1,D2);
                            L1 = max(L1,CFAR);
                            L1 = max(L1,D3);
                                     
                            if L3 < szL3 && L2 < szL2 && L1 < szL1
                                target =[]; 
                                fprintf('%4d %3d %3d %4d %4d %6d %6d %6d %6d-- random ', testNum, Ntx, Nrx, RFFT, DFFT, ceil(L3/1024), ceil(L2/1024),  ceil(L1/1024), BPM);
					        	
                                %random case
					        	config((testNum-1)*2+1,1) = Nrx;%gNumRxAntennas
					        	config((testNum-1)*2+1,2) = RFFT;%gNumAdcSamples = number of range bins (Range FFT size)
					        	config((testNum-1)*2+1,3) = Ntx;%gNumTxAntennas
					        	config((testNum-1)*2+1,4) = 64;%gNumAngleBins - It can be 32 or 16 but never checked it. We can try one test with 32.
					        	config((testNum-1)*2+1,5) = DFFT*Ntx;%gNumChirpsPerFrame = number of Doppler bins (Doppler FFT size) * number of Tx antennas
					        	config((testNum-1)*2+1,6) = BPM;%bpmEnabled
                                config((testNum-1)*2+1,7) = 4;%gNumTargets
					        	config((testNum-1)*2+1,8) = 10;%gSnrdB -  It does not need to be, just set this to have some noise.
					        	
                                minDistRng = 1/4*RFFT;
                                minDistDop = 1/5*DFFT;
                                minDist = sqrt(minDistRng^2 + minDistDop^2);
                                for tgtIdx = 1:4
                                    
                                    %Get range/doppler index
                                    for kk =1:100
                                        target{tgtIdx}.range = (mod(round(rand*4*0.2*RFFT+2*randn),round(0.8*RFFT)));
                                        target{tgtIdx}.doppler = (mod(round(rand*4*0.5*DFFT+2*randn),DFFT));
                                        minD = sqrt(RFFT^2+DFFT^2);
                                        if(tgtIdx>1)
                                            for jj = tgtIdx-1:-1:1
                                                if sqrt(abs(target{tgtIdx}.range - target{jj}.range)^2 + abs(target{tgtIdx}.doppler - target{jj}.doppler)^2) < minD
                                                    minD = sqrt(abs(target{tgtIdx}.range - target{jj}.range)^2 + abs(target{tgtIdx}.doppler - target{jj}.doppler)^2);
                                                end
                                            end
                                            if minD > minDist
                                                break;
                                            end
                                        end
                                    end
                                   % fprintf('\n tgtIdx = %d, mind = %d/%d kk = %d\n', tgtIdx, round(minD), round(minDist), kk)
                                    
                                    if target{tgtIdx}.doppler >= DFFT/2
					        			target{tgtIdx}.doppler = target{tgtIdx}.doppler - DFFT;
					        		end
                                    
                                    target{tgtIdx}.azimuth = (mod(round(rand*0.25*AFFT+randn),AFFT));
                                    target{tgtIdx}.amplitude = round(500 + 10*randn);
					        		
					        		if tgtIdx > 1
					        	        for temp = 1:tgtIdx-1
					        		        if target{tgtIdx}.range == target{temp}.range
					        					if abs(target{tgtIdx}.doppler - target{temp}.doppler) <= 2											
					        					    target{tgtIdx}.doppler = target{tgtIdx}.doppler + 10;
					        				    end
					        			    end
					        			end
					        	    end
                                    fprintf('[%d] = %3d %3d %3d %3d, ', tgtIdx, target{tgtIdx}.amplitude, target{tgtIdx}.range, target{tgtIdx}.doppler, target{tgtIdx}.azimuth);
					        		
					        		config((testNum-1)*2+1, (9  + 4*(tgtIdx-1))) = target{tgtIdx}.amplitude;
					        		config((testNum-1)*2+1, (10 + 4*(tgtIdx-1))) = target{tgtIdx}.azimuth;
					        		config((testNum-1)*2+1, (11 + 4*(tgtIdx-1))) = target{tgtIdx}.range;
					        		config((testNum-1)*2+1, (12 + 4*(tgtIdx-1))) = target{tgtIdx}.doppler;
					        		
                                end
                                fprintf('\n');
					        	hold off
                                plot([0 DFFT-1 DFFT-1 0 0],[0 0 RFFT-1 RFFT-1 0],'b')
                                hold on
                                for tgtIdx = 1:4
                                    plot(target{tgtIdx}.doppler, target{tgtIdx}.range,'ro','MarkerFaceColor',[1 0 0]);
                                end
                                pause(.5)
					        	
					        	fprintf('                                                      min/max');
                                %min/max case
					        	config((testNum-1)*2+2,1) = config((testNum-1)*2+1,1);
					        	config((testNum-1)*2+2,2) = config((testNum-1)*2+1,2);
					        	config((testNum-1)*2+2,3) = config((testNum-1)*2+1,3);
					        	config((testNum-1)*2+2,4) = config((testNum-1)*2+1,4);
					        	config((testNum-1)*2+2,5) = config((testNum-1)*2+1,5);
                                config((testNum-1)*2+2,6) = BPM;
					        	config((testNum-1)*2+2,7) = 2;%has only 2 targets
					        	config((testNum-1)*2+2,8) = config((testNum-1)*2+1,8);
                                
					        	for tgtIdx = 1:2
					        		if tgtIdx == 1
					        		    %min range/doppler
					        		    target{tgtIdx}.range = 1;
					        		    target{tgtIdx}.doppler = 1;
					        		else
					        		    %max range.doppler
					        		    target{tgtIdx}.range = RFFT-1;
					        		    target{tgtIdx}.doppler = DFFT/2 -1;
                                    end
                                    
					        		% random azimuth and amplitude
                                    target{tgtIdx}.azimuth = (mod(round(rand*0.25*AFFT+randn),AFFT));
                                    target{tgtIdx}.amplitude = round(500 + 10*randn);
                                    fprintf('[%d] = %3d %3d %3d %3d, ', tgtIdx, target{tgtIdx}.amplitude, target{tgtIdx}.range, target{tgtIdx}.doppler, target{tgtIdx}.azimuth);
					        		
					        		config((testNum-1)*2+2, (9  + 4*(tgtIdx-1))) = target{tgtIdx}.amplitude;
					        		config((testNum-1)*2+2, (10 + 4*(tgtIdx-1))) = target{tgtIdx}.azimuth;
					        		config((testNum-1)*2+2, (11 + 4*(tgtIdx-1))) = target{tgtIdx}.range;
					        		config((testNum-1)*2+2, (12 + 4*(tgtIdx-1))) = target{tgtIdx}.doppler;
					        		
                                end
					        	fprintf('\n');
					        	hold off
                                plot([0 DFFT-1 DFFT-1 0 0],[0 0 RFFT-1 RFFT-1 0],'b')
                                hold on
                                for tgtIdx = 1:4
                                    plot(target{tgtIdx}.doppler, target{tgtIdx}.range,'ro','MarkerFaceColor',[1 0 0]);
                                end
                                pause(.5)
					        	
                                testNum = testNum + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end

fid = fopen('xwr16xx_data_path_test_config.bin','wb');
fwrite(fid, (testNum-1)*2,'int32');
for row = 1:(testNum-1)*2 
    for col = 1:24
        fwrite(fid,config(row,col),'int32');
    end
end
fclose (fid);

                         