//
//  PhoneNumberUtilityTests.swift
//  PhoneNumberKitTests
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

@testable import PhoneNumberKit
import XCTest

final class PhoneNumberUtilityTests: XCTestCase {
    private var sut: PhoneNumberUtility!

    override func setUp() {
        super.setUp()
        sut = PhoneNumberUtility()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testMetadataMainCountryFetch() {
        let countryMetadata = self.sut.metadataManager.mainTerritory(forCode: 1)
        XCTAssertEqual(countryMetadata?.codeID, "US")
    }

    func testMetadataMainCountryFunction() {
        let countryName = self.sut.mainCountry(forCode: 1)!
        XCTAssertEqual(countryName, "US")
        let invalidCountry = self.sut.mainCountry(forCode: 992_322)
        XCTAssertNil(invalidCountry)
    }

    // Invalid american number, GitHub issue #8 by j-pk
    func testInvalidNumberE() {
        do {
            let phoneNumber = try sut.parse("202 00e 0000", withRegion: "US")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Valid indian number, GitHub issue #235
    func testValidNumber6() {
        do {
            let phoneNumber = try sut.parse("6297062979", withRegion: "IN")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTAssert(true)
        } catch {
            XCTFail()
        }
    }

    // Bool checker, GitHub issue #325
    func testValidNumberBool() {
        XCTAssert(sut.isValidPhoneNumber("6297062979", withRegion: "IN"))
        XCTAssertFalse(sut.isValidPhoneNumber("202 00e 0000", withRegion: "US"))
    }

    // Invalid american number, GitHub issue #9 by lobodin
    func testAmbiguousFixedOrMobileNumber() {
        do {
            let phoneNumber = try sut.parse("+16307792428", withRegion: "US")
            print(self.sut.format(phoneNumber, toType: .e164))
            let type = phoneNumber.type
            XCTAssertEqual(type, PhoneNumberType.fixedOrMobile)
        } catch {
            XCTFail()
        }
    }

    // Invalid UK number, GitHub pr by dulaccc
    func testInvalidGBNumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the GB region
            let phoneNumber = try sut.parse("+44629996885")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Invalid BE number, GitHub pr by dulaccc
    func testInvalidBENumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the BE region
            let phoneNumber = try sut.parse("+32910853865")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Invalid DZ number, GitHub pr by dulaccc
    func testInvalidDZNumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the DZ region
            let phoneNumber = try sut.parse("+21373344376")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Invalid CN number, GitHub pr by dulaccc
    func testInvalidCNNumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the CN region
            let phoneNumber = try sut.parse("+861500376135")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Invalid IT number, GitHub pr by dulaccc
    func testInvalidITNumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the IT region
            let phoneNumber = try sut.parse("+390762613915")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Invalid ES number, GitHub pr by dulaccc
    func testInvalidESNumbers() {
        do {
            // libphonenumber reports this number as invalid
            // and it's true, this is a French mobile number combined with the ES region
            let phoneNumber = try sut.parse("+34312431110")
            print(self.sut.format(phoneNumber, toType: .e164))
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    // Italian number with a leading zero
    func testItalianLeadingZero() {
        let testNumber = "+39 0549555555"
        do {
            let phoneNumber = try sut.parse(testNumber)
//            XCTAssertEqual(phoneNumber.toInternational(), testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 39)
            XCTAssertEqual(phoneNumber.nationalNumber, 549_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, true)
        } catch {
            XCTFail()
        }
    }

    // French number with extension
    func testNumberWithExtension() {
        let testNumber = "+33-689-5-5555-5 ext. 84"
        do {
            let phoneNumber = try sut.parse(testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.numberExtension, "84")
            XCTAssertEqual(phoneNumber.nationalNumber, 689_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    // American number with short extension
    func testAlternativeNumberWithExtension() {
        let testNumber = "2129316760 x28"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "US", ignoreType: false)
            XCTAssertEqual(phoneNumber.countryCode, 1)
            XCTAssertEqual(phoneNumber.numberExtension, "28")
            XCTAssertEqual(phoneNumber.nationalNumber, 2_129_316_760)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    // French number with a plus
    func testValidNumberWithPlusNoWhiteSpace() {
        let testNumber = "+33689555555"
        do {
            let phoneNumber = try sut.parse(testNumber)
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), testNumber)
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .international, withPrefix: false), "6 89 55 55 55")
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.nationalNumber, 689_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
            // XCTAssertEqual(phoneNumber.type, PhoneNumberType.mobile)
        } catch {
            XCTFail()
        }
    }

    // 'Noisy' Japanese number with a plus
    func testValidNumberWithPlusWhiteSpace() {
        let testNumber = "+81 601 55-5-5 5 5"
        do {
            let phoneNumber = try sut.parse(testNumber)
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+81601555555")
            XCTAssertEqual(phoneNumber.countryCode, 81)
            XCTAssertEqual(phoneNumber.nationalNumber, 601_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    // English number with an American IDD (default region for testing environment)
    func testValidNumberWithAmericanIDDNoWhiteSpace() {
        let testNumber = "011447739555555"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "US")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+447739555555")
            XCTAssertEqual(phoneNumber.countryCode, 44)
            XCTAssertEqual(phoneNumber.nationalNumber, 7_739_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    // 'Noisy' Brazilian number with an American IDD (default region for testing environment)
    func testValidNumberWithAmericanIDDWhiteSpace() {
        let testNumber = "01155 11 9 6 555 55 55"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "US")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+5511965555555")
            XCTAssertEqual(phoneNumber.countryCode, 55)
            XCTAssertEqual(phoneNumber.nationalNumber, 11_965_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    //  American number with no prefix from an American phone (default region for testing environment)
    func testValidLocalNumberWithNoPrefixNoWhiteSpace() {
        let testNumber = "2015555555"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "US")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+12015555555")
            XCTAssertEqual(phoneNumber.countryCode, 1)
            XCTAssertEqual(phoneNumber.nationalNumber, 2_015_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    //  'Noisy' American number with no prefix from an American phone (default region for testing environment)
    func testValidLocalNumberWithNoPrefixWhiteSpace() {
        let testNumber = "500-2-55-555-5"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "US")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+15002555555")
            XCTAssertEqual(phoneNumber.countryCode, 1)
            XCTAssertEqual(phoneNumber.nationalNumber, 5_002_555_555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    func testValidAENumberWithHinduArabicNumerals() {
        let testNumber = "+٩٧١٥٠٠٥٠٠٥٥٠"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "AE")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+971500500550")
            XCTAssertEqual(phoneNumber.countryCode, 971)
            XCTAssertEqual(phoneNumber.nationalNumber, 500_500_550)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    func testValidAENumberWithMixedHinduArabicNumerals() {
        let testNumber = "+٩٧١5٠٠5٠٠55٠"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "AE")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+971500500550")
            XCTAssertEqual(phoneNumber.countryCode, 971)
            XCTAssertEqual(phoneNumber.nationalNumber, 500_500_550)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    func testValidAENumberWithEasternArabicNumerals() {
        let testNumber = "+۹۷۱۵۰۰۵۰۰۵۵۰"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "AE")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+971500500550")
            XCTAssertEqual(phoneNumber.countryCode, 971)
            XCTAssertEqual(phoneNumber.nationalNumber, 500_500_550)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    func testValidAENumberWithMixedEasternArabicNumerals() {
        let testNumber = "+۹۷۱5۰۰5۰۰55۰"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "AE")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+971500500550")
            XCTAssertEqual(phoneNumber.countryCode, 971)
            XCTAssertEqual(phoneNumber.nationalNumber, 500_500_550)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        } catch {
            XCTFail()
        }
    }

    //  Invalid number too short
    func testInvalidNumberTooShort() {
        let testNumber = "+44 32"
        do {
            let phoneNumber = try sut.parse(testNumber)
            _ = self.sut.format(phoneNumber, toType: .e164)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    //  Invalid number too long
    func testInvalidNumberTooLong() {
        let testNumber = "+44 3243894723084732047023472"
        do {
            let phoneNumber = try sut.parse(testNumber)
            _ = self.sut.format(phoneNumber, toType: .e164)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    //  Invalid number not a number, random string
    func testInvalidNumberNotANumber() {
        let testNumber = "ae4c08c6-be33-40ef-a417-e5166e307b5e"
        do {
            let phoneNumber = try sut.parse(testNumber)
            _ = self.sut.format(phoneNumber, toType: .e164)
            XCTFail()
        } catch {
            XCTAssert(true)
        }
    }

    //  Invalid number invalid format
    func testInvalidNumberNotANumberInvalidFormat() {
        XCTAssertThrowsError(try sut.parse("+33(02)689555555")) { error in
            XCTAssertEqual(error as? PhoneNumberError, PhoneNumberError.invalidNumber)
        }
    }

    //  Test that metadata initiates correctly by checking all countries
    func testAllCountries() {
        let allCountries = self.sut.allCountries()
        XCTAssert(!allCountries.isEmpty)
    }

    //  Test code for country function -  valid country
    func testCodeForCountryValid() {
        XCTAssertEqual(self.sut.countryCode(for: "FR"), 33)
    }

    //  Test code for country function - invalid country
    func testCodeForCountryInvalid() {
        XCTAssertEqual(self.sut.countryCode(for: "FOOBAR"), nil)
    }

    //  Test countries for code function
    func testCountriesForCodeValid() {
        XCTAssertEqual(self.sut.countries(withCode: 1)?.count, 25)
    }

    //  Test countries for code function
    func testCountriesForCodeInvalid() {
        XCTAssertEqual(self.sut.countries(withCode: 424_242)?.count, nil)
    }

    //  Test region code for number function
    func testGetRegionCode() {
        guard let phoneNumber = try? sut.parse("+39 3123456789") else {
            XCTFail()
            return
        }
        XCTAssertEqual(self.sut.getRegionCode(of: phoneNumber), "IT")
    }

    // In the case of multiple
    // countries sharing a calling code, the one
    // indicated with "isMainCountryForCode" in the metadata should be first.
    func testGetRegionCodeForTollFreeFromUS() {
        guard let phoneNumber = try? sut.parse("+1 888 579 4458") else {
            XCTFail()
            return
        }
        XCTAssertEqual(self.sut.getRegionCode(of: phoneNumber), "US")
    }

    // RU number with KZ country code
    func testValidRUNumberWithKZRegion() {
        let testNumber = "+7 916 195 55 58"
        do {
            let phoneNumber = try sut.parse(testNumber, withRegion: "KZ")
            XCTAssertEqual(self.sut.format(phoneNumber, toType: .e164), "+79161955558")
            XCTAssertEqual(phoneNumber.countryCode, 7)
            XCTAssertEqual(phoneNumber.nationalNumber, 9_161_955_558)
            XCTAssertEqual(phoneNumber.leadingZero, false)
            XCTAssertEqual(phoneNumber.regionID, "RU")
        } catch {
            XCTFail()
        }
    }

    func testValidKZNumbersWithInternationalPrefix() {
        let numbers = ["+7 (777)110-85-31", "+77777056982", "+7(701)977-75-05"]
        numbers.forEach { XCTAssertTrue(sut.isValidPhoneNumber($0, withRegion: "KZ")) }
        numbers.forEach { XCTAssertTrue(sut.isValidPhoneNumber($0)) }
        numbers.forEach { XCTAssertTrue(sut.isValidPhoneNumber($0, withRegion: "RU")) }
    }

    func testValidKZNumbersWithoutInternationalPrefix() {
        let numbers = ["(777)110-85-31", "7777056982", "(701)977-75-05"]
        numbers.forEach { XCTAssertTrue(sut.isValidPhoneNumber($0, withRegion: "KZ")) }
        numbers.forEach {
            do {
                let phoneNumber = try sut.parse($0, withRegion: "RU")
                XCTAssertEqual(phoneNumber.countryCode, 7)
                XCTAssertEqual(phoneNumber.regionID, "KZ")
            } catch {
                XCTFail()
            }
        }
    }

    func testValidCZNumbers() throws {
        let numbers = ["420734593819", "+420734593819", "734593819"]
        try numbers.forEach {
            let phoneNumber = try sut.parse($0, withRegion: "CZ")
            XCTAssertNotNil(phoneNumber)

            let formatted = sut.format(phoneNumber, toType: .e164)
            XCTAssertEqual(formatted, "+420734593819")
        }
    }

    func testValidDENumbers() throws {
        let numbers = ["491713369876", "+491713369876", "01713369876", "1713369876"]
        try numbers.forEach {
            let phoneNumber = try sut.parse($0, withRegion: "DE")
            XCTAssertNotNil(phoneNumber)

            let formatted = sut.format(phoneNumber, toType: .e164)
            XCTAssertEqual(formatted, "+491713369876")
        }
    }

    func testValidITNumbers() throws {
        let numbers = ["3939035695","00393939035695", "+393939035695", "393939035695"]
        try numbers.forEach {
            let phoneNumber = try sut.parse($0, withRegion: "IT")
            XCTAssertNotNil(phoneNumber)

            let formatted = sut.format(phoneNumber, toType: .e164)
            XCTAssertEqual(formatted, "+393939035695")
        }
    }
}
