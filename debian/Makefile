install:
	install debian/cruisecontrol.sh ${prefix}/usr/share/cruisecontrol/bin/cruisecontrol
	install debian/ant_j2se.sh ${prefix}/usr/share/cruisecontrol/bin/.ant_j2se
	install -m 644 main/dist/cruisecontrol*.jar ${prefix}/usr/share/cruisecontrol/dist
#	install -m 644 main/lib/activation.jar main/lib/fast-md5.jar main/lib/org.mortbay.jetty.jar main/lib/x10.jar \
	               main/lib/mx4j.jar main/lib/mx4j-tools.jar main/lib/mx4j-remote.jar main/lib/smack.jar main/lib/comm.jar \
	               ${prefix}/usr/share/cruisecontrol/lib
	install -m 644 main/lib/activation.jar main/lib/x10.jar main/lib/smack.jar main/lib/comm.jar \
								 main/lib/jug-lgpl-2.0.0.jar main/lib/xstream-1.2.2.jar \
								 ${prefix}/usr/share/cruisecontrol/lib
# Not yet available in lenny :
	install -m 664 main/lib/fast-md5.jar binaryrelease/lib/jetty-6.1.11.jar \
								 binaryrelease/lib/jetty-ajp-6.1.11.jar binaryrelease/lib/jetty-util-6.1.11.jar \
	               ${prefix}/usr/share/cruisecontrol/lib

	install -m 644 debian/log4j.xml debian/cruisecontrol.xml ${prefix}/etc/cruisecontrol
	install -m 644 binaryrelease/etc/jetty.xml binaryrelease/etc/realm.properties ${prefix}/etc/cruisecontrol
	install -m 644 binaryrelease/dashboard-config.xml ${prefix}/etc/cruisecontrol

	install -m 644 reporting/dashboard/jsunit/java/lib/jasper-compiler.jar \
								 reporting/dashboard/jsunit/java/lib/jasper-runtime.jar \
	               ${prefix}/usr/share/cruisecontrol/lib

	cp -r reporting/jsp/webcontent/xsl ${prefix}/usr/share/cruisecontrol/reporting
	cp -r reporting/jsp/webcontent/css ${prefix}/usr/share/cruisecontrol/reporting
	unzip -d ${prefix}/usr/share/cruisecontrol/webapps/cruisecontrol/ reporting/jsp/dist/cruisecontrol.war
	unzip -d ${prefix}/usr/share/cruisecontrol/webapps/dashboard/ reporting/dashboard/dist/dashboard.war
	find ${prefix} -name ".svn" | xargs rm -rf

createlib:
	mkdir -p ${prefix}/lib
	ln -fs `pwd`/main/lib/activation.jar `pwd`/main/lib/fast-md5.jar `pwd`/main/lib/org.mortbay.jetty.jar `pwd`/main/lib/x10.jar \
	       `pwd`/main/lib/mx4j.jar `pwd`/main/lib/mx4j-tools.jar `pwd`/main/lib/mx4j-remote.jar \
	       `pwd`/main/lib/smack.jar `pwd`/main/lib/comm.jar `pwd`/main/lib/inmemorysfee-1.0.0.jar \
	       ${prefix}/lib
	ln -fs `pwd`/main/lib/checkstyle-all-3.1.jar `pwd`/main/lib/emma.jar `pwd`/main/lib/emma_ant.jar \
	       ${prefix}/lib
	ln -fs /usr/share/java/log4j-1.2.jar /usr/share/java/jdom1.jar /usr/share/java/commons-net.jar \
	       /usr/share/java/gnumail.jar /usr/share/java/inetlib.jar /usr/share/java/commons-logging.jar \
	       ${prefix}/lib
