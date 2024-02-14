*** Settings ***
Library  SeleniumLibrary
Library    String
Test Setup    Run Keywords    Open Browser    https://www.google.com/    chrome
...    AND    Maximize Browser Window
...    AND    Open    ${BASE_URL}
...    AND    Set Selenium Speed  ${SELSPEED}
Test Teardown    Close Browser

*** Variables ***
${BROWSER}   chrome
${SELSPEED}  0.2s
${BASE_URL}    http://127.0.0.1:5000/

${VALID_EMAIL}    user123@email.com
${VALID_USERNAME}    user123
${VALID_PASSWORD}    password123

${INVALID_EMAIL}    email@email@email
${INVALID_USERNAME}    invalidusername'""
${INVALID_PASSWORD}    invalidpassword'""

${ADMIN_USERNAME}    admin
${ADMIN_PASSWORD}    admin

*** Test Cases ***

Create_account
    Create account: Invalid username and password    ${BASE_URL}    ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    Create account: Invalid email format    ${BASE_URL}    ${INVALID_USERNAME}    ${INVALID_EMAIL}    ${VALID_PASSWORD}
    Create account: Username already exists    ${BASE_URL}    ${VALID_USERNAME}    ${INVALID_EMAIL}    ${VALID_PASSWORD}
    # Create account: Valid IDs    ${BASE_URL}        # Change values manually

Login_Logout
    Login    ${BASE_URL}   ${VALID_USERNAME}    ${VALID_PASSWORD}
    Logout
    Checking: Logout alert
    Checking: Logout URL

Buying_selling
    Login    ${BASE_URL}   ${VALID_USERNAME}    ${VALID_PASSWORD}
    Checking: Currency
    Checking: 10K$ assigned to new users
    Checking: Pop-up can be closed in 3 different ways
    Checking: Info pop-up on buying works + correct data
    Checking: Funds adjust to buying and selling
    Checking: Sufficient funds for buying + alert
    Checking: How many items are in the cart
    Sell button + Reset cart
    Checking: How many items are in the cart after selling
    Logout

Habilitations
    Checking: Market can only be accessed by users
    Login    ${BASE_URL}   ${VALID_USERNAME}    ${VALID_PASSWORD}
    Checking: Admin panel can only be accessed by admin
    Logout
    Login admin    ${BASE_URL}    ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}
    Checking: admin can view items and users tables
    Logout

Admin
    Login admin    ${BASE_URL}   ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}
    Update item
    Delete item
    Delete user

*** Keywords ***
Create account: Valid IDs
    [Arguments]    ${BASE_URL}
    open    ${BASE_URL}
    click    link=Getting Started
    click    link=Create Account
    click    id=username
    type    id=username    coco
    type    id=email_address    coco@y.com
    type    id=password1    coco
    type    id=password2    coco
    click    id=submit

Login
    [Arguments]    ${BASE_URL}   ${VALID_USERNAME}    ${VALID_PASSWORD}
    click    link=Login
    click    id=username
    type    id=username    ${VALID_USERNAME}
    type    id=password    ${VALID_PASSWORD}
    click    id=submit
    open    ${BASE_URL}market

Login admin
    [Arguments]    ${BASE_URL}   ${ADMIN_USERNAME}    ${ADMIN_PASSWORD}
    click    link=Login
    click    id=username
    type    id=username    ${ADMIN_USERNAME}
    type    id=password    ${ADMIN_PASSWORD}
    click    id=submit
    open    ${BASE_URL}market
    open    ${BASE_URL}admin
    ${ADMIN_ITEMS}      Get Text    xpath=/html/body/div/div[1]
    Should Contain    ${ADMIN_ITEMS}    Control Products

Create account: Invalid username and password
    [Arguments]    ${BASE_URL}   ${INVALID_USERNAME}    ${INVALID_PASSWORD}
    open    ${BASE_URL}
    click    link=Login
    click    id=username
    type    id=username    ${INVALID_USERNAME}
    type    id=password    ${INVALID_PASSWORD}
    click    id=submit
    ${ALERT}=    Get Text    //div[@class='alert alert-danger'] 
    Should Match Regexp    ${ALERT}    Username and password are not match! Please try again

Create account: Invalid email format
    [Arguments]    ${BASE_URL}    ${VALID_USERNAME}    ${INVALID_EMAIL}    ${VALID_PASSWORD}
    open    ${BASE_URL}
    click    link=Getting Started
    click    link=Create Account
    click    id=username
    type    id=username    ${INVALID_USERNAME}
    type    id=email_address    ${INVALID_EMAIL}
    type    id=password1    ${VALID_PASSWORD}
    type    id=password2    ${VALID_PASSWORD}
    click    id=submit
    ${ALERT}=    Get Text    //div[@class='alert alert-danger'] 
    Should Match Regexp    ${ALERT}    ['Invalid email address.']

Create account: Username already exists
    [Arguments]    ${BASE_URL}    ${VALID_USERNAME}    ${INVALID_EMAIL}    ${VALID_PASSWORD}
    open    ${BASE_URL}
    click    link=Getting Started
    click    link=Create Account
    click    id=username
    type    id=username    ${VALID_USERNAME}
    type    id=email_address    ${INVALID_EMAIL}
    type    id=password1    ${VALID_PASSWORD}
    type    id=password2    ${VALID_PASSWORD}
    click    id=submit
    ${ALERT}=    Get Text    //div[@class='alert alert-danger'] 
    Should Match Regexp    ${ALERT}    ['Username already exists! Please try a different username.']

Logout
    open    ${BASE_URL}
    click    link=Logout

Checking: Logout alert
    ${LOGOUT_POPUP}=    Get Text    //div[@class='alert alert-info']    
    Should Match Regexp    ${LOGOUT_POPUP}    You have been logged out!

Checking: Logout URL
    ${LOGOUT_URL}=    Get Location
    Should Be Equal As Strings    ${LOGOUT_URL}    ${BASE_URL}

Checking: Market can only be accessed by users
    open    ${BASE_URL}market
    ${LOGOUT_POPUP}=    Get Text    //div[@class='alert alert-info']    
    Should Match Regexp    ${LOGOUT_POPUP}    Please log in to access this page.

Checking: Admin panel can only be accessed by admin
    open    ${BASE_URL}admin
    ${LOGOUT_POPUP}=    Get Text    //div[@class='alert alert-danger']    
    Should Match Regexp    ${LOGOUT_POPUP}    Please login as admin to access the admin panel!

Checking: Currency
    ${CURRENCY}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a 
    Should Contain    ${CURRENCY}    $
    Should Not Contain    ${CURRENCY}    £
    Should Not Contain    ${CURRENCY}    €

Checking: 10K$ assigned to new users
    ${FUNDS}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a 
    Should Contain    ${FUNDS}    10,000

Checking: Funds adjust to buying and selling
    open    ${BASE_URL}market
    ${INI_FUNDS}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a
    ${INI_FUNDS}    Remove String    ${INI_FUNDS}    ,    $
    ${INI_FUNDS}    Convert To Integer  ${INI_FUNDS}
    ${INI_FUNDS}    Convert To String  ${INI_FUNDS}
    ${ITEM_PRICE}=    Get Text    //tbody/tr[1]/td[3]
    ${ITEM_PRICE}    Remove String    ${ITEM_PRICE}    ,    $
    ${ITEM_PRICE}    Convert To Integer    ${ITEM_PRICE}
    ${ITEM_PRICE}    Convert To String    ${ITEM_PRICE}
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='Info'])[1]/following::button[1]
    click    id=submit
    ${UPD_FUNDS}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a
    ${UPD_FUNDS}    Remove String    ${UPD_FUNDS}    ,    $
    ${UPD_FUNDS}    Convert To Integer    ${UPD_FUNDS}
    ${UPD_FUNDS}    Convert To String    ${UPD_FUNDS}
    ${DIFF}=    Evaluate   ${INI_FUNDS} - ${ITEM_PRICE}
    ${DIFF}    Convert To String    ${DIFF}
    Should Be Equal    ${DIFF}    ${UPD_FUNDS}
    ${INI_FUNDS}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a
    ${INI_FUNDS}    Remove String    ${INI_FUNDS}    ,    $
    ${INI_FUNDS}    Convert To Integer  ${INI_FUNDS}
    ${INI_FUNDS}    Convert To String  ${INI_FUNDS}
    ${ITEM_PRICE}=    Get Text    xpath=/html/body/div[2]/div[2]/div/div[2]/div/div/p/strong
    ${ITEM_PRICE}    Remove String    ${ITEM_PRICE}    ,    $
    ${ITEM_PRICE}    Convert To Integer    ${ITEM_PRICE}
    ${ITEM_PRICE}    Convert To String    ${ITEM_PRICE}
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='IPhone 15'])[3]/following::button[1]
    click    xpath=//div[@id='Sell-1']/div/div/div[2]/form/div/input[2]
    ${UPD_FUNDS}=    Get Text   //*[@id="navbarNav"]/ul[2]/li[1]/a
    ${UPD_FUNDS}    Remove String    ${UPD_FUNDS}    ,    $
    ${UPD_FUNDS}    Convert To Integer    ${UPD_FUNDS}
    ${UPD_FUNDS}    Convert To String    ${UPD_FUNDS}
    ${DIFF}=    Evaluate   ${INI_FUNDS} + ${ITEM_PRICE}
    ${DIFF}    Convert To String    ${DIFF}
    Should Be Equal    ${DIFF}    ${UPD_FUNDS}

Checking: Info pop-up on buying works + correct data
    ${INI_NAME}=    Get Text     //tbody/tr[2]/td[1]
    ${INI_BARCODE}=    Get Text    //tbody/tr[2]/td[2]
    ${INI_PRICE}=    Get Text    //tbody/tr[2]/td[3]
    ${INI_DSCRPT}=    Get Text    //tr[2]/td[4]
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='MacBook Air'])[4]/following::button[1]
    ${INFO_NAME}=    Get Text    //*[@id="Info-2"]/div/div/div[1]
    Should Contain    ${INFO_NAME}    ${INI_NAME}
    ${INFO_TABLE}=    Get Text    //*[@id="Info-2"]/div/div/div[2]
    Should Contain    ${INFO_TABLE}    ${INI_BARCODE}    ${INI_PRICE}    ${INI_DSCRPT}  
    click    xpath=//div[@id='Info-2']/div/div/div[3]/button

Checking: Pop-up can be closed in 3 different ways
    Set Selenium Implicit Wait    0.2
    click    xpath=//tbody/tr[1]/td[5]/button[1]
    Set Selenium Implicit Wait    0.2
    click    xpath=//div[@id='Info-1']/div/div/div[3]/button
    Set Selenium Implicit Wait    0.2
    click    xpath=//tbody/tr[1]/td[5]/button[1]
    Set Selenium Implicit Wait    0.2
    click    xpath=//div[@id='Info-1']/div/div/div/button/span
    Set Selenium Implicit Wait    0.2
    click    xpath=//tbody/tr[1]/td[5]/button[1]
    Set Selenium Implicit Wait    0.2
    click    id=Info-1

Checking: Sufficient funds for buying + alert
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='Info'])[2]/following::button[1]
    click    xpath=//div[@id='Buy-2']/div/div/div[2]/div/input[2]
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='Info'])[2]/following::button[1]
    click    xpath=//div[@id='Buy-3']/div/div/div[2]/div/input[2]
    ${LOGOUT_POPUP}=    Get Text    xpath=/html/body/div[1]    
    Should Match Regexp    ${LOGOUT_POPUP}    Unfortunately, you don't have enough money to purchase
    
Checking: How many items are in the cart
    ${COUNT_ITEMS}    Get Element Count   //div[@class='card-body']
    ${COUNT_ITEMS}    Convert To String    ${COUNT_ITEMS}
    Should Be Equal    ${COUNT_ITEMS}    1

Sell button + Reset cart
    Page Should Contain Element    xpath=/html/body/div[2]/div[2]/div/div[2]/div/div/button
    click    xpath=(.//*[normalize-space(text()) and normalize-space(.)='MacBook Air'])[3]/following::button[1]
    click    xpath=//div[@id='Sell-2']/div/div/div[2]/form/div/input[2]

Checking: admin can view items and users tables
    open    ${BASE_URL}admin
    Page Should Contain Element    xpath=/html/body/div/div[1]
    Page Should Contain Element    xpath=/html/body/div/div[2]

Checking: How many items are in the cart after selling
    ${COUNT_ITEMS}    Get Element Count   //div[@class='card-body']
    ${COUNT_ITEMS}    Convert To String    ${COUNT_ITEMS}
    Should Be Equal    ${COUNT_ITEMS}    0

Update item
    open    ${BASE_URL}admin
    click    xpath=/html[1]/body[1]/div[1]/div[1]/table[1]/tbody[1]/tr[1]/td[5]/button[1]
    type    id=form1    "New name"
    type    id=form2    "0"
    type    id=form3    "New owner"

Delete item
    open    ${BASE_URL}admin
    click    xpath=/html[1]/body[1]/div[1]/div[1]/table[1]/tbody[1]/tr[1]/td[5]/button[2]
    Page Should Not Contain Element    xpath=/html[1]/body[1]/div[1]/div[1]/table[1]/tbody[1]/tr[1]/td[2]

Delete user
    open    ${BASE_URL}admin
    click     xpath=/html[1]/body[1]/div[1]/div[2]/table[1]/tbody[1]/tr[5]/td[5]/button[1]
    Page Should Not Contain Element    xpath=/html[1]/body[1]/div[1]/div[2]/table[1]/tbody[1]/tr[5]/td[2]

# _____________________________________________________________________________________________


open
    [Arguments]    ${element}
    Go To          ${element}

clickAndWait
    [Arguments]    ${element}
    Click Element  ${element}

click
    [Arguments]    ${element}
    Click Element  ${element}

sendKeys
    [Arguments]    ${element}    ${value}
    Press Keys     ${element}    ${value}

submit
    [Arguments]    ${element}
    Submit Form    ${element}

type
    [Arguments]    ${element}    ${value}
    Input Text     ${element}    ${value}

verifyValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

verifyText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

verifyElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

verifyVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

verifyTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

verifyTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertConfirmation
    [Arguments]                  ${value}
    Alert Should Be Present      ${value}

assertText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

assertElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

assertVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

assertTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

assertTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForText
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForValue
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

waitForElementPresent
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

waitForVisible
    [Arguments]                  ${element}
    Page Should Contain Element  ${element}

waitForTitle
    [Arguments]                  ${title}
    Title Should Be              ${title}

waitForTable
    [Arguments]                  ${element}  ${value}
    Element Should Contain       ${element}  ${value}

doubleClick
    [Arguments]           ${element}
    Double Click Element  ${element}

doubleClickAndWait
    [Arguments]           ${element}
    Double Click Element  ${element}

goBack
    Go Back

goBackAndWait
    Go Back

runScript
    [Arguments]         ${code}
    Execute Javascript  ${code}

runScriptAndWait
    [Arguments]         ${code}
    Execute Javascript  ${code}

setSpeed
    [Arguments]           ${value}
    Set Selenium Timeout  ${value}

setSpeedAndWait
    [Arguments]           ${value}
    Set Selenium Timeout  ${value}

verifyAlert
    [Arguments]              ${value}
    Alert Should Be Present  ${value}
