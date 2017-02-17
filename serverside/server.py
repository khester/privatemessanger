from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
import sqlalchemy
import sqlite3
import json
from sqlalchemy.orm import mapper
import urllib2
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Column, DateTime, String, Integer, ForeignKey, func, MetaData,Table
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.orm import relationship, backref
from sqlalchemy.ext.declarative import declarative_base
engine = create_engine('sqlite:///testdata2', echo=True)
newsession = sessionmaker()
Base = declarative_base()
newsession.configure(bind=engine)
session = newsession()
import base64
import encodings



class User(Base):
     __tablename__ = 'user'
     id = Column(Integer, primary_key=True)
     phonenumber = Column(String)
     name = Column(String)
     password = Column(String)
     newAction = Column(String)
     #conversations = relationship('Conversation',  backref="user")
     def __repr__(self):
        return "<User(phonenumber='%s', name='%s', newAction='%s', password='%s')>" % (
                            self.phonenumber, self.name, self.newAction, self.password)


class Conversation(Base):
    __tablename__ = 'conversation'
    id = Column(Integer, primary_key=True)
    name = Column(String)
    userlist = Column(String)
    #messagelist = relationship(Message)
    def __repr__(self):
        return "<Conversation(name='%s', userlist='%s')>" % (
                            self.name, self.userlist)

class UserConversationLink(Base):
    __tablename__ = 'userconversationlink'
    user_id = Column(Integer, ForeignKey('user.id'), primary_key=True)
    conversation_id = Column(Integer, ForeignKey('conversation.id'), primary_key=True)

'''
class Message(Base):
    __tablename__ = 'message'
    id = Column(Integer, primary_key=True)
    senderid = Column(String)
    sendername = Column(String)
    text = Column(String)
    conversation = relationship('Conversation')


'''
Base.metadata.create_all(engine)




class privatechat(Protocol):



    def connectionMade(self):
        print "Guest client added."
 
    def connectionLost(self, reason):
        if hasattr(self, 'server_name'):
            for c in self.factory.users:
                # telnet includes \n automatically
                #c.transport.write(self.server_name + " has left.\n")
                print("conn lost")
            print self.server_name + " has left"
        print "Guest client left."




    def sendMessageToConversation(text, senderid,sendername,conversationid):
        print text


    def dataReceived(self, data):
        print(data)

        if data[:4] == "key>":
            print("in key")
        elif data[:4] =="reg>":
            print("reg")
            data = data[4:]
            print(data)
            resultjsonstring = json.loads(data)
            name = resultjsonstring['name']
            phone = resultjsonstring['phone']
            password = resultjsonstring['password']
            newUser = User(name = name, password = password, newAction = "registration",phonenumber=phone)
            print("here")
            session.add(newUser)
            session.commit()
            resultjsonstring['id']=newUser.id
            self.transport.write(json.dumps(resultjsonstring))
            print("it's ok")
        elif data[:4] == "usr>":
            print(data)
            data = data[4:]
            print(self)
            data = data.strip()
            resultjsonstring = json.loads(data)
            userConnectionPhone = resultjsonstring['phone']
            userConnectionPassword = resultjsonstring['password']

            newUserConnection = session.query(User).filter(User.phonenumber==userConnectionPhone).first()


            try:
                resultjsonstring['id'] = newUserConnection.id
                resultjsonstring['name'] = newUserConnection.name
                if newUserConnection.password == userConnectionPassword:
                    #######################
                    self.factory.users[self] = userConnectionPhone
                    print(self.factory.users)
                    self.server_name = data.strip()
                    print("you are logged on!!!!!!!!!!!")
                    print data.strip() + " has logged on."
                    resultjsonstring['error']='false'
                    self.transport.write(json.dumps(resultjsonstring))
                else:
                    print("bad password")
                    resultjsonstring['error']='true'
                    self.transport.write(json.dumps(resultjsonstring))
            except:
                    print("bad login")
                    resultjsonstring['error']='true'
                    self.transport.write(json.dumps(resultjsonstring))


        elif data[:4] == "msg>":
            data = data[4:]

            resultjsonstring = json.loads(data)
            print(resultjsonstring['type'])
            if resultjsonstring['type'] == "newmessage":
                conversationid = resultjsonstring['conversationid']
                messages = resultjsonstring['message']
                print(self.server_name)
                for message in messages:
                    text = message['text']
                    senderid = message['senderid']
                    senderdisplayname = message['senderDisplayName']
                print(text, senderdisplayname,senderid)
                currentConversation = session.query(Conversation).filter(Conversation.id == conversationid).first()
                print("##########################")
                print(currentConversation.name, currentConversation.userlist, currentConversation.id)
                userlist = json.loads(currentConversation.userlist)
                mycurrentphone = ""


                try:
                    if self.factory.users[self]==userlist['seconduserphone']:
                        mycurrentphone=userlist['firstuserphone']
                    elif self.factory.users[self]==userlist['firstuserphone']:
                        mycurrentphone=userlist['seconduserphone']

                    print("##########################")
                    for c in self.factory.users:
                            if self.factory.users[c] == mycurrentphone :
                                c.transport.write(data)
                                print("send data")
                except:
                    userarray = []
                    for user in userlist:
                        userarray.append(user['phone'])

                    for c in self.factory.users:
                        print(self.factory.users[c])
                        if self.factory.users[c] in userarray:
                            print(self.factory.users[c])
                            c.transport.write(json.dumps(resultjsonstring))
                            print("send data")

                        print("ds")



            elif resultjsonstring['type'] == "createconversation":
                newConvercastion = Conversation(name=str(resultjsonstring['conversationname']),userlist=json.dumps(resultjsonstring['users']))

                session.add(newConvercastion)
                session.commit()
                idConversation = newConvercastion.id
                resultjsonstring['conversationid']=idConversation
                userlistforsend = []
                print(idConversation)

                for usr in resultjsonstring['users']:
                    usrphone = usr['phone']
                    userlistforsend.append(usrphone)
                    print(usrphone)
                userlistforsend.append(self.factory.users[self])
                #print(json.dumps(resultjsonstring))
                for c in self.factory.users:
                    print(self.factory.users[c])
                    if self.factory.users[c] in userlistforsend:
                        print(self.factory.users[c])
                        c.transport.write(json.dumps(resultjsonstring))
                        print("send data")



            elif resultjsonstring['type'] == "checkuser":
                checkUserPhone = resultjsonstring['seconduserphone']
                conversationName = "Myconversation"
                firstUserPhone = resultjsonstring['firstuserphone']
                userListDict = {"firstuserphone":firstUserPhone, "seconduserphone":checkUserPhone}
                userListJsonDump = json.dumps(userListDict)
                newUserConnectionCheck = session.query(User).filter(User.phonenumber == checkUserPhone).first()
                if newUserConnectionCheck:
                    firstUser = session.query(User).filter(User.phonenumber == firstUserPhone).first()
                    print("hello world")
                    newConvercastion = Conversation(name=conversationName,userlist=userListJsonDump)
                    session.add(newConvercastion)
                    session.commit()
                    idConversation = newConvercastion.id
                    print('here')

                    firstCheckUserDict = { "registered": "true",  "phone": checkUserPhone, "userid":newUserConnectionCheck.id,  "conversationname": newUserConnectionCheck.name,  "conversationid":  idConversation,  "type": "checkuser"}
                    secondCheckUserDict = { "registered": "true",  "phone": firstUserPhone, "userid":firstUser.id,  "conversationname": firstUser.name,  "conversationid":  idConversation,  "type": "checkuser"}

                    for c in self.factory.users:
                        if c==self:
                            c.transport.write((json.dumps(firstCheckUserDict)))
                        elif c==checkUserPhone:
                            c.transport.write((json.dumps(secondCheckUserDict)))
                    print("User Found")
                else:
                    checkUserDict = {"registered": "false",  "phone": "None", "userid":0, "conversationname": "None",  "conversationid":  0,  "type": "checkuser"}
                    for c in self.factory.users:
                         c.transport.write((json.dumps(checkUserDict)))
                    print("User Not FOund:", checkUserPhone)



            else:
                print("i don't know")


            if self in self.factory.users:
              username = self.factory.users[self]
              for c in self.factory.users:
                      # telnet includes \n automatically
                      if data[-1] != "\n":
                          data += "\n"
                      #c.transport.write(data)

            else:
              #self.transport.write("Invalid request. Please log in.\n")
              print("invalid request")

        else:
          #self.transport.write("Improper protocol. Use usr> or msg>\n")
          print("use protocol")



factory = Factory()
factory.users = {}
factory.protocol = privatechat

reactor.listenTCP(1112, factory)
print "TalkToMe server started"
reactor.run()

