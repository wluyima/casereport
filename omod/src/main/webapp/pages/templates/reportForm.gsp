<!--

    This Source Code Form is subject to the terms of the Mozilla Public License,
    v. 2.0. If a copy of the MPL was not distributed with this file, You can
    obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
    the terms of the Healthcare Disclaimer located at http://openmrs.org/license.

    Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
    graphic logo is a trademark of OpenMRS Inc.

-->

<script type="text/javascript">
    emr.loadMessages(["casereport.submitted", "casereport.report.form.title", "casereport.seeLogs"]);
</script>

<script type="text/ng-template" id="casereport-template-processing">
    <span id="casereport-sending">
        ${ui.message("casereport.sending")}<span id="casereport-blinker">...</span>
    </span>
    <img id="casereport-processing" src="${ui.resourceLink("casereport", "images/processing.gif")}" />
</script>

<style type="text/css">
    @keyframes blinker {
        75% { opacity: 0; }
    }

    .ngdialog-content {
         width: 380px !important;
         height: 64px !important;
         padding-top: 8px !important;
    }

    #casereport-processing {
        width: 380px !important;
        height: 26px !important;
    }

    #casereport-sending {
        margin-left: 18px !important;
    }

    #casereport-blinker {
        animation: blinker 0.7s linear infinite;
    }
</style>

<h2 id="casereport-reportTitle" />

<form class="simple-form-ui" name="caseReportForm" novalidate ng-submit="submitCaseReport()">
    {{ updateFormTitle(caseReport.reportForm.fullName) }}
    <div ng-show="previousCaseReports.length > 0">
        <a ng-click="showPreviousReports = !showPreviousReports" class="casereport-pointer casereport-no-underline">
            <span ng-show="!showPreviousReports">
                <i class="icon-angle-down" /> ${ui.message("casereport.showPreviousReports")}
            </span>
            <span ng-show="showPreviousReports">
                <i class="icon-angle-up" /> ${ui.message("casereport.hidePreviousReports")}
            </span>
        </a>
        <div ng-show="showPreviousReports">
            <br>
            <div id="casereport-prev-reports">
                <ul>
                    <li ng-repeat="prevReport in previousCaseReports | orderBy:'resolutionDate':true">
                        {{ prevReport.resolutionDate | serverDate }} - {{ prevReport.reportForm.triggers | omrsDisplay }}
                    </li>
                </ul>
            </div>
        </div>
    </div>
    <br>
    <table class="casereport-form-table" cellpadding="0" cellspacing="0">
        <tr>
            <th valign="top">${ui.message("general.name")}</th>
            <td valign="top">{{ caseReport.reportForm.fullName }}</td>
        </tr>
        <tr>
            <th valign="top">${ui.message("Patient.identifier")}</th>
            <td valign="top">{{ caseReport.reportForm.patientIdentifier.value }}</td>
        </tr>
        <tr>
            <th valign="top">${ui.message("Person.gender")}</th>
            <td valign="top">{{ caseReport.reportForm.gender }}</td>
        </tr>
        <tr>
            <th valign="top">${ui.message("casereport.birthdate")}</th>
            <td valign="top">{{ formatDate(caseReport.reportForm.birthdate) }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.dead">
            <th valign="top">${ui.message("Person.dead")}</th>
            <td valign="top">{{ caseReport.reportForm.dead }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.dead && caseReport.reportForm.deathdate">
            <th valign="top">${ui.message("casereport.deathdate")}</th>
            <td valign="top">{{ formatDate(caseReport.reportForm.deathdate) }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.dead && caseReport.reportForm.causeOfDeath">
            <th valign="top">${ui.message("casereport.causeOfDeath")}</th>
            <td valign="top">{{ caseReport.reportForm.causeOfDeath | omrsDisplay }}</td>
        </tr>
        <tr>
            <th valign="top">${ui.message("casereport.triggers")}</th>
            <td valign="top">
                <span>
                    <span ng-repeat="trigger in caseReport.reportForm.triggers track by \$index">
                        <span class="casereport-trigger-lozenge">
                            {{ trigger.value }}
                            <a class="casereport-no-underline" ng-show="caseReport.reportForm.triggers.length > 1">
                                <i class="icon-remove delete-action" title="${ui.message("general.remove")}"
                                   ng-click="remove(\$index)" />
                            </a>
                        </span>
                    </span>
                 </span>
            </td>
        </tr>
        <tr ng-show="caseReport.reportForm.mostRecentViralLoads.length > 0
                    || caseReport.reportForm.mostRecentCd4Counts.length > 0
                    || caseReport.reportForm.mostRecentHivTests.length > 0">
            <th valign="top">${ui.message("casereport.diagnosticData")}</th>
            <td valign="top">
                <table id="casereport-data-table" cellpadding="0" cellspacing="0">
                    <tr>
                        <th valign="top">${ui.message("casereport.viralLoad")}</th>
                        <td valign="top" ng-repeat="viralLoad in caseReport.reportForm.mostRecentViralLoads">
                            {{ viralLoad.value }} <span class="casereport-xx-small-faint">({{ viralLoad.date | serverDate}})</span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentViralLoads.length < 3">
                            <span ng-show="caseReport.reportForm.mostRecentViralLoads.length == 0">
                                ${ui.message("casereport.none.found")}
                            </span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentViralLoads.length < 2"></td>
                        <td ng-show="caseReport.reportForm.mostRecentViralLoads.length < 1"></td>
                    </tr>
                    <tr>
                        <th valign="top">${ui.message("casereport.cd4Count")}</th>
                        <td valign="top" ng-repeat="cd4Count in caseReport.reportForm.mostRecentCd4Counts">
                            {{ cd4Count.value }} <span class="casereport-xx-small-faint">({{ cd4Count.date | serverDate}})</span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentCd4Counts.length < 3">
                            <span ng-show="caseReport.reportForm.mostRecentCd4Counts.length == 0">
                                ${ui.message("casereport.none.found")}
                            </span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentCd4Counts.length < 2"></td>
                        <td ng-show="caseReport.reportForm.mostRecentCd4Counts.length < 1"></td>
                    </tr>
                    <tr>
                        <th valign="top">${ui.message("casereport.hivTest")}</th>
                        <td valign="top" ng-repeat="hivTest in caseReport.reportForm.mostRecentHivTests">
                            {{ hivTest.value }} <span class="casereport-xx-small-faint">({{ hivTest.date | serverDate}})</span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentHivTests.length < 3">
                            <span ng-show="caseReport.reportForm.mostRecentHivTests.length == 0">
                                ${ui.message("casereport.none.found")}
                            </span>
                        </td>
                        <td ng-show="caseReport.reportForm.mostRecentHivTests.length < 2"></td>
                        <td ng-show="caseReport.reportForm.mostRecentHivTests.length < 1"></td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr ng-show="caseReport.reportForm.currentHivWhoStage">
            <th valign="top">${ui.message("casereport.whoClassification")}</th>
            <td valign="top">{{ caseReport.reportForm.currentHivWhoStage.value }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.currentHivMedications.length > 0">
            <th valign="top">${ui.message("casereport.arvs")}</th>
            <td valign="top">{{ getValues(caseReport.reportForm.currentHivMedications) | omrsDisplay }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.mostRecentArvStopReason">
            <th valign="top">${ui.message("casereport.reasonArvsStopped")}</th>
            <td valign="top">{{ caseReport.reportForm.mostRecentArvStopReason.value }}</td>
        </tr>
        <tr ng-show="caseReport.reportForm.lastVisitDate">
            <th valign="top">${ui.message("casereport.lastVisit")}</th>
            <td valign="top">{{ caseReport.reportForm.lastVisitDate.value | serverDate}}</td>
        </tr>
        <tr>
            <th valign="top">${ui.message("casereport.comments")}</th>
            <td valign="top"><textarea ng-model="caseReport.reportForm.comments" cols="54"></textarea></td>
        </tr>
        <tr>
            <th class="casereport-row-separator"></th>
            <td class="casereport-row-separator"></td>
        </tr>
        <tr>
            <th valign="top">${ui.message("casereport.signature")}</th>
            <td valign="top">
                ${ui.format(context.authenticatedUser)}
                <span class="right">
                    <button type="button" class="cancel" ui-sref="list">${ui.message('general.cancel')}</button>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <button type="submit" class="confirm right">${ui.message('general.submit')}</button>
                </span>
            </td>
        </tr>
    </table>
</form>