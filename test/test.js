#!/usr/bin/env node

'use strict';

var execSync = require('child_process').execSync,
    expect = require('expect.js'),
    path = require('path'),
    webdriver = require('selenium-webdriver');

var by = webdriver.By,
    Keys = webdriver.Key,
    until = webdriver.until;

process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';

if (!process.env.USERNAME || !process.env.PASSWORD) {
    console.log('USERNAME and PASSWORD env vars need to be set');
    process.exit(1);
}

describe('Application life cycle test', function () {
    this.timeout(0);

    var firefox = require('selenium-webdriver/firefox');
    var server, browser = new firefox.Driver();

    before(function (done) {
        var seleniumJar= require('selenium-server-standalone-jar');
        var SeleniumServer = require('selenium-webdriver/remote').SeleniumServer;
        server = new SeleniumServer(seleniumJar.path, { port: 4444 });
        server.start();

        done();
    });

    after(function (done) {
        browser.quit();
        server.stop();
        done();
    });

    var LOCATION = 'taigatest';
    var TEST_TIMEOUT = 10000;
    var PROJECT_NAME = 'testproject';
    var PROJECT_DESCRIPTION = 'testdescription';
    var USER_STORY_SUBJECT = 'someteststory';
    var app;

    function waitForElement(elem, callback) {
         browser.wait(until.elementLocated(elem), TEST_TIMEOUT).then(function () {
            browser.wait(until.elementIsVisible(browser.findElement(elem)), TEST_TIMEOUT).then(function () {
                callback();
            });
        });
    }

    function login(callback) {
        browser.manage().deleteAllCookies();
        browser.get('https://' + app.fqdn + '/login?next=%252Fprofile');

        waitForElement(by.name('username'), function () {
            browser.findElement(by.name('username')).sendKeys(process.env.USERNAME);
            browser.findElement(by.name('password')).sendKeys(process.env.PASSWORD);
            browser.findElement(by.className('login-form')).submit();

            waitForElement(by.xpath('//h4[text()="Your profile"]'), callback);
        });
    }

    function userStoryExists(callback) {
        browser.get('https://' + app.fqdn + '/project/' + process.env.USERNAME + '-' + PROJECT_NAME + '/us/1');

        waitForElement(by.xpath('//div[text()="' + USER_STORY_SUBJECT + '"]'), callback);
    }

    xit('build app', function () {
        execSync('cloudron build', { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
    });

    it('install app', function () {
        execSync('cloudron install --new --wait --location ' + LOCATION, { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
    });

    it('can get app information', function () {
        var inspect = JSON.parse(execSync('cloudron inspect'));

        app = inspect.apps.filter(function (a) { return a.location === LOCATION; })[0];

        expect(app).to.be.an('object');
    });

    it('can login', login);

    it('can dismiss tutorial', function (done) {
        browser.get('https://' + app.fqdn);

        waitForElement(by.className('introjs-skipbutton'), function () {
            browser.findElement(by.className('introjs-skipbutton')).sendKeys(Keys.ENTER);

            // give some time to ack
            setTimeout(done, 5000);
        });
    });

    it('can create project', function (done) {
        browser.get('https://' + app.fqdn);

        waitForElement(by.className('create-project-button'), function () {

            // click wont work
            browser.findElement(by.className('create-project-button')).sendKeys(Keys.ENTER);

            waitForElement(by.className('button-next'), function () {
                browser.findElement(by.className('button-next')).click();

                waitForElement(by.name('name'), function () {
                    browser.findElement(by.name('name')).sendKeys(PROJECT_NAME);
                    browser.findElement(by.xpath('//textarea[@name="description"]')).sendKeys(PROJECT_DESCRIPTION);

                    browser.findElement(by.xpath('//button[@title="Create"]')).sendKeys(Keys.ENTER);

                    waitForElement(by.xpath('//span[text()="' + PROJECT_NAME + '"]'), done);
                });
            });
        });
    });

    it('can create user story', function (done) {
        browser.get('https://' + app.fqdn + '/project/' + process.env.USERNAME + '-' + PROJECT_NAME + '/backlog');

        waitForElement(by.xpath('//a[@title="+ Add a new User Story"]'), function () {
            browser.findElement(by.xpath('//a[@title="+ Add a new User Story"]')).sendKeys(Keys.ENTER);

            waitForElement(by.name('subject'), function () {
                browser.findElement(by.name('subject')).sendKeys(USER_STORY_SUBJECT);

                browser.findElement(by.xpath('//button[@title="Create"]')).sendKeys(Keys.ENTER);

                waitForElement(by.xpath('//span[text()="' + USER_STORY_SUBJECT + '"]'), done);
            });
        });
    });

    it('user story exists', userStoryExists);

    it('backup app', function () {
        execSync('cloudron backup --app ' + app.id, { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
    });

    it('restore app', function () {
        execSync('cloudron restore --app ' + app.id, { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
    });

    it('can login', login);
    it('user story is still present', userStoryExists);

    it('move to different location', function () {
        browser.manage().deleteAllCookies();
        execSync('cloudron install --location ' + LOCATION + '2 --app ' + app.id, { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
        var inspect = JSON.parse(execSync('cloudron inspect'));
        app = inspect.apps.filter(function (a) { return a.location === LOCATION + '2'; })[0];
        expect(app).to.be.an('object');
    });

    it('can login', login);
    it('user story is still present', userStoryExists);

    it('can delete project', function (done) {
        browser.get('https://' + app.fqdn + '/project/' + process.env.USERNAME + '-' + PROJECT_NAME + '/admin/project-profile/details');

        waitForElement(by.className('delete-project'), function () {
            browser.findElement(by.className('delete-project')).click();

            waitForElement(by.xpath('//a[@title="Yes, I\'m really sure"]'), function () {
                browser.findElement(by.xpath('//a[@title="Yes, I\'m really sure"]')).click();

                waitForElement(by.className('create-project-button'), done);
            });
        });
    });

    it('uninstall app', function () {
        execSync('cloudron uninstall --app ' + app.id, { cwd: path.resolve(__dirname, '..'), stdio: 'inherit' });
    });
});
