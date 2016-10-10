# GCC Explorer
FROM cli

RUN git clone https://github.com/ynh/cpp-to-assembly.git
WORKDIR cpp-to-assembly
# RUN find ./ -type f -exec \
#     sed -i 's/c++0x/c++11/g' {} +
# RUN find ./ -type f -exec \
#     sed -i 's/c99/cpp11/g' {} +
RUN npm install --silent > /dev/null\
 && npm install --silent coffee-script > /dev/null

EXPOSE 8080
CMD ["npm", "start"]
