


/////////////////////////////////////////////
// Get XML formatted data from the web.
// 1/6/08 Bob S. - Created
//
//  Assumptions: single XML line looks like:
//    <tag>data</tag> or <tag>data
//
// Get current weather observation for Raleigh from weather.gov in XML format
//
//////////////////////////////////////////////

// Include description files for other libraries used (if any)
#include <string.h>
#include <TubeLine.h>




////from another parsing sketch


#define BUFFER_SIZE 256

// Maximum number of attributes the parser can handle in one tag
#define ATTR_LEN 10

#define STRIP_LENGTH 32 //32 LEDs on this strip
long strip_colors[STRIP_LENGTH];

long tube_colors[10];




long bg;
int SDI = 2; //Red wire (not the red 5V wire!)
int CKI = 3; //Green wire
int ledPin = 13; //On board LED



typedef enum {
  IN_TEXT, IN_TAG
}
ParserState;

typedef struct {
  char *name, *val;
}
NameVal;




class UXMLParser {
private:
  char buff[BUFFER_SIZE];
  uint16_t buffLen;
  ParserState state;

  void buffAppend(char c);
  void buffClear();
  void parseTag();
  char* findName(char* p, char* endP, size_t *len);
  char* findVal(char* p, size_t *len);
  char charBeforeName(char* p);
  char charBeforeTagEnd(char* p);
  bool isName(char c);
public:
  UXMLParser();
  void parse(char c);

  virtual void handleOpenTag(char *tag, NameVal attr[], uint8_t attrLen) = 0;
  virtual void handleCloseTag(char *tag) = 0;
  virtual void handleText(char *text) = 0;
};

UXMLParser::UXMLParser() {
  buffClear();
  state = IN_TEXT;
}

void UXMLParser::buffAppend(char c) {
  buff[buffLen] = c;
  if (buffLen < BUFFER_SIZE) {
    buffLen++;
  }
}

void UXMLParser::buffClear() {
  buffLen = 0;
}

bool UXMLParser::isName(char c) {
  return isalnum(c) | c=='.' | c==':' | c=='-' | c=='_';
}

char* UXMLParser::findName(char* p, char* endP, size_t *len) {
  while (p<endP && !isName(*p))
    p++; // find start of name
  *len = 0;
  if (p>=endP) return 0;
  while (p+*len < endP && isName(p[*len])) (*len)++; // find end of name
  if (p+*len>=endP) return 0;
  return p;
}

char* UXMLParser::findVal(char* p, size_t *len) {
  char qmark;
  while ((*p)!='"' && (*p)!='\'') p++; // find start of val
  qmark = *p;
  p++;
  *len = 0;
  while (p[*len]!=qmark) (*len)++; // find end of val
  return p;
}

char UXMLParser::charBeforeName(char* p) {
  while(!isalnum(*p)) {
    if (!isspace(*p)) return *p;
    p++;
  }
  return 0;
}

char UXMLParser::charBeforeTagEnd(char* p) {
  p -= 2;
  while(isspace(*p)) {
    p--;
  }
  return *p;
}

void UXMLParser::parseTag() {
  char *p, *endP, *tag, c;
  NameVal attrList[ATTR_LEN];
  uint8_t attrP;
  bool openTag, closeTag, emptyTag;
  size_t len;

  p = buff;
  endP = buff + buffLen;
  p++; // skip the '<'

  openTag = true;
  closeTag = false;
  c = charBeforeName(p);
  if (c == '?') return;   // skip this tag
  if (c == '/') {
    openTag = false;
    closeTag = true;
  }

  c = charBeforeTagEnd(endP);
  if (c == '/') {
    closeTag = true;
  }

  tag = findName(p, endP, &len);
  if (tag==0) return;

  emptyTag = tag[len] == '>';
  tag[len] = 0;
  p = tag+len+1;

  attrP=0;
  if (!emptyTag) {
    while (attrP<ATTR_LEN) {
      char *attrN, *attrV;

      attrN = findName(p, endP, &len);
      if (attrN==0) break;        // reached end of tag
      attrN[len] = 0;
      p = attrN+len+1;

      attrV = findVal(p, &len);
      attrV[len] = 0;
      p = attrV+len+1;

      attrList[attrP].name = attrN;
      attrList[attrP].val = attrV;

      attrP++;
    }
  }

  if (openTag) handleOpenTag(tag, attrList, attrP);
  if (closeTag) handleCloseTag(tag);
}

void UXMLParser::parse(char c) {
  switch (state) {
  case IN_TEXT:
    if (c=='<') {
      buffAppend(0);
      handleText(buff);
      buffClear();
      buffAppend(c);
      state = IN_TAG;
    }
    else {
      buffAppend(c);
    }
    break;

  case IN_TAG:
    if (c=='>') {
      buffAppend(c);
      parseTag();
      buffClear();
      state = IN_TEXT;
    }
    else {
      buffAppend(c);
    }
    break;

  default:
    break;
  }
}

// -- End of library -----------------------------------------------------------------


// -- Start of test/example program --------------------------------------------------


// UXML uses inheritance, so you have to create your own class,
// and overweite the methods handleOpenTag, handleCloseTag and handleText.
class TestParser : 
public UXMLParser {
public:
  TestParser();
  virtual void handleOpenTag(char *tag, NameVal attr[], uint8_t attrLen);
  virtual void handleCloseTag(char *tag);
  virtual void handleText(char *text);
};

TestParser::TestParser() : 
UXMLParser() {
}

// what should be done, if a tag opens?
void TestParser::handleOpenTag(char *tag, NameVal attr[], uint8_t attrLen) {
  String line;

 // Serial.print("handleOpenTag: ");
 // Serial.print(tag);
  String tagS = tag;
  for(int i=0; i<attrLen; i++) {
 /*   Serial.print(" ");
    Serial.print(attr[i].name);
    Serial.print("='");
    Serial.print(attr[i].val);
    Serial.println("'");*/
    String nom = attr[i].name;
    String val = attr[i].val;
    String id;
    String currentState;
 //   Serial.println("TAG:"+tagS);
  //  Serial.println("ATTRIBUTE IS:"+nom);
  
   if (tagS == "Line"){
        if (nom == "ID"){              
        id = val;    
         Serial.println("LINE ID IS:"+id);
         
        }
    }
  
    if (tagS == "Line"){
        if (nom == "Name"){       
        nom = val;          
         Serial.println("LINE IS:"+nom);
        }
    }
    if(tagS == "Status"){
       if (nom == "Description"){
         currentState = val;
        Serial.println("STATUS IS:"+currentState);
       } 
    }
//    TubeLine 
    //Serial.println("name:"+nom);
    //    if (


 // Serial.println();
  }
}

// what should be done, if a tag closes?
void TestParser::handleCloseTag(char *tag) {
  //Serial.print("handleCloseTag: ");
  //Serial.println(tag);
}

// what should be done, with text?
void TestParser::handleText(char *text) {
 // Serial.print("handleText: '");
  //Serial.print(text);
  //Serial.println("'");
}

TestParser testParser = TestParser();
//char test[] = "<bc></bc>< a n = 'value' asdf='' jkl=\"'\"> b <emptyTag / >< / a >";



//#include <Ethernet.h>

// Define Constants
// Max string length may have to be adjusted depending on data to be extracted
#define MAX_STRING_LEN  400

// Setup vars
char tagStr[MAX_STRING_LEN] = "";
char dataStr[MAX_STRING_LEN] = "";
char tmpStr[MAX_STRING_LEN] = "";
char endTag[3] = {
  '<', '/', '\0'};
int len;
TubeLine lines[13];

// Flags to differentiate XML tags from document elements (ie. data)
boolean tagFlag = false;
boolean dataFlag = false;

// Ethernet vars
byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte ip[] = { 
  192, 168, 0, 41 };
byte server[] = { 
  140, 90, 113, 200 }; // www.weather.gov

// Start ethernet client
//Client client(server, 80);

void setup()
{
  Serial.begin(9600);
  Serial.println("Starting WebWx");
  Serial.println("connecting...");
  //Ethernet.begin(mac, ip);
  delay(1000);
  /*
  if (client.connect()) {
   Serial.println("connected");
   client.println("GET /xml/current_obs/KRDU.xml HTTP/1.0");    
   client.println();
   delay(2000);
   } else {
   Serial.println("connection failed");
   }    */
}

void loop() {

  // Read serial data in from web:
  while (Serial.available()) {
   // delay(10);
    serialEvent();
  }

  /* if (!client.connected()) {
   //Serial.println();
   Serial.println("Disconnected");
   client.stop();
   
   // Time until next update
   //Serial.println("Waiting");
   for (int t = 1; t <= 15; t++) {
   delay(60000); // 1 minute
   }
   */
  /*  if (client.connect()) {
   //Serial.println("Reconnected");
   Serial.println("GET /xml/current_obs/KRDU.xml HTTP/1.0");    
   client.println();
   delay(2000);
   } 
   else {
   Serial.println("Reconnect failed");
   }      
   }*/
}

void serialEvent(){
   char inChar =   (char)Serial.read();
  testParser.parse(inChar);
  
}


// Process each char from web
void serialEventz() {
//delay(10);
  // Read a char
  //  char inChar = client.read();
  char inChar =   (char)Serial.read();
    //Serial.print(".");

    if (inChar == '<') {
      addChar(inChar, tmpStr);
      tagFlag = true;
      dataFlag = false;

    } 
    else if (inChar == '>') {
      addChar(inChar, tmpStr);

      if (tagFlag) {      
        strncpy(tagStr, tmpStr, strlen(tmpStr)+1);
      }

      // Clear tmp
      clearStr(tmpStr);

      tagFlag = false;
      dataFlag = true;      

    } 
    else if (inChar != 10) {
      if (tagFlag) {
        // Add tag char to string
        addChar(inChar, tmpStr);

        // Check for </XML> end tag, ignore it
        if ( tagFlag && strcmp(tmpStr, endTag) == 0 ) {
          clearStr(tmpStr);
          tagFlag = false;
          dataFlag = false;
        }
      }

      if (dataFlag) {
        // Add data char to string
        addChar(inChar, dataStr);
      }
    }  

  // If a LF, process the line
  if (inChar =='>' ) {

    
     Serial.print("tagStr: ");
     Serial.println(tagStr);
     Serial.print("dataStr: ");
     Serial.println(dataStr);  
//      if ( strcmp(tagStr, searchTag) == 0 ) {
     if (strcmp(tagStr, "<Line ") == 0){
     Serial.print("IS A LINE!");       
     }

    // Clear all strings
    clearStr(tmpStr);
    clearStr(tagStr);
    clearStr(dataStr);

    // Clear Flags
    tagFlag = false;
    dataFlag = false;
  }
}

/////////////////////
// Other Functions //
/////////////////////

// Function to clear a string
void clearStr (char* str) {
  int len = strlen(str);
  for (int c = 0; c < len; c++) {
    str[c] = 0;
  }
}

//Function to add a char to a string and check its length
void addChar (char ch, char* str) {
  char *tagMsg  = "<TRUNCATED_TAG>";
  char *dataMsg = "-TRUNCATED_DATA-";

  // Check the max size of the string to make sure it doesn't grow too
  // big.  If string is beyond MAX_STRING_LEN assume it is unimportant
  // and replace it with a warning message.
  if (strlen(str) > MAX_STRING_LEN - 2) {
    if (tagFlag) {
      clearStr(tagStr);
      strcpy(tagStr,tagMsg);
    }
    if (dataFlag) {
      clearStr(dataStr);
      strcpy(dataStr,dataMsg);
    }

    // Clear the temp buffer and flags to stop current processing
    clearStr(tmpStr);
    tagFlag = false;
    dataFlag = false;

  } 
  else {
    // Add char to string
    str[strlen(str)] = ch;
  }
}

// Function to check the current tag for a specific string
boolean matchTag (char* searchTag) {
  if ( strcmp(tagStr, searchTag) == 0 ) {
    return true;
  } 
  else {
    return false;
  }
}



