rm marvin

#g++ -std=c++11 -Wfatal-errors -O3 -o marvin marvin.cpp -I. -I/usr/local/cuda/include -L/usr/local/cuda/lib64 -lcudart -lcublas -lcudnn

export PATH=$PATH:/home/tianyi.cui/my_cuda/cuda-7.5/bin

nvcc -std=c++11 -O3 -o marvin marvin.cu -I. -I/home/tianyi.cui/my_cuda/cuda/include/ -I/home/tianyi.cui/my_cuda/cuda-7.5/include -LI/home/tianyi.cui/my_cuda/cuda/lib64 -L/home/tianyi.cui/my_cuda/cuda-7.5/lib64 -lcudart -lcublas -lcudnn


export LD_LIBRARY_PATH=LD_LIBRARY_PATH:/home/tianyi.cui/my_cuda/cuda-7.5/lib64



# case 
# ./marvin train mnist/lenet.json


#./marvin train mnist/lenet.json

#./marvin train ImageNet/alexnet.json

#./marvin train ImageNet/alexnet.json ImageNet/caffe_pretrained.tensor

# ./marvin train ImageNet/alexnet.json ImageNet/caffe_pretrained.tensor 450000

#valgrind --leak-check=yes ./marvin train mnist/lenet.json

# g++ -c -Wfatal-errors -o marvin.o marvin.cpp -I. -I/usr/local/cuda/include -I./cudnn-6.5-osx-v2  -I/opt/local/include 

# gcc -v -o marvin -L/usr/local/cuda/lib -L./cudnn-6.5-osx-v2 -lcudart -lcublas -lcudnn -lm -lstdc++

# gcc -o mnistCUDNN mnistCUDNN.o -L/usr/local/cuda/lib -L/Users/jxiao/Dropbox/visiongpu/DeepND/cudnn-6.5-osx-v2 -L/Users/jxiao/Dropbox/visiongpu/DeepND/cuDNN/cudnn-sample-v2/FreeImage/lib/darwin -L/opt/local/lib -lnppi -lnppc -lfreeimage -lcudart -lcublas -lcudnn -lm -lstdc++

#./marvin test DSS/DSSnet_extractfea_gt.json fc5,fc6 DSS/fc5.tensor,DSS/fc6.tensor
