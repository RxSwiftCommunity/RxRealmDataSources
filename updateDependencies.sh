#First we install pods
pod update

#Then we update our carthage repo and build frameworks
carthage update --platform iOS --no-build

sh ./installDependencies.sh