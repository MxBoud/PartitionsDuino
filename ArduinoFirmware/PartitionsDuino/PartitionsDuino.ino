
// PARTITIONSDUINO Arduino Firmware - By MxBoud - March 2018

byte pin = 2;
bool buttonState = LOW;
bool firstTime = LOW;
bool buttonLaunched = LOW;
bool goToNextPage = LOW;
int debounce = 100;
unsigned long pressedTime;

void setup() {
  pinMode(pin, INPUT);
  Serial.begin(9600);
}

void loop() {
  if (digitalRead(pin)) {
    buttonState = HIGH;
    if (!firstTime) {
      pressedTime = millis();
    }
    if (pressedTime + debounce < millis() && !buttonLaunched)
    {
      goToNextPage = HIGH;
      buttonLaunched = HIGH;
    }
    firstTime = HIGH;
  }
  else {// Not working yet...
    if (goToNextPage) {
      Serial.println("NextPage");
    }
    if (goToPreviousPage) {
      Serial.println("PreviousPage");
    }
    goToNextPage = LOW;
    buttonState = LOW;
    firstTime = LOW;
    buttonLaunched = LOW;
  }
}
