/**
 * This Source Code Form is subject to the terms of the Mozilla Public License,
 * v. 2.0. If a copy of the MPL was not distributed with this file, You can
 * obtain one at http://mozilla.org/MPL/2.0/. OpenMRS is also distributed under
 * the terms of the Healthcare Disclaimer located at http://openmrs.org/license.
 * 
 * Copyright (C) OpenMRS Inc. OpenMRS is a registered trademark and the OpenMRS
 * graphic logo is a trademark of OpenMRS Inc.
 */
package org.openmrs.module.casereport;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.openmrs.api.APIException;
import org.openmrs.api.context.Context;
import org.openmrs.module.BaseModuleActivator;
import org.openmrs.module.ModuleActivator;
import org.openmrs.module.reporting.cohort.definition.CohortDefinition;
import org.openmrs.module.reporting.cohort.definition.SqlCohortDefinition;
import org.openmrs.module.reporting.definition.DefinitionContext;
import org.openmrs.module.reporting.evaluation.parameter.Parameter;
import org.openmrs.scheduler.SchedulerService;
import org.openmrs.scheduler.TaskDefinition;

/**
 * This class contains the logic that is run every time this module is either started or stopped.
 */
public class CaseReportActivator extends BaseModuleActivator {
	
	protected Log log = LogFactory.getLog(getClass());
	
	/**
	 * @see ModuleActivator#willRefreshContext()
	 */
	public void willRefreshContext() {
		log.info("Refreshing Case Report Module");
	}
	
	/**
	 * @should fail for a query with no name
	 * @should fail for a query with no sql
	 * @should ignore a cohort query with a duplicate name
	 * @should save a cohort queries with a name that matches a retired duplicate
	 * @should load queries and register them with the reporting module
	 * @should add the case report tasks if they do not exist
	 * @see ModuleActivator#contextRefreshed()
	 */
	public void contextRefreshed() {
		loadQueries();
		log.info("Case Report Module refreshed");
	}
	
	private void loadQueries() {
		log.info("Loading queries...");
		
		List<SqlCohortQueryLoader> loaders = new ArrayList<SqlCohortQueryLoader>();
		loaders.addAll(Context.getRegisteredComponents(SqlCohortQueryLoader.class));
		if (loaders.isEmpty()) {
			loaders.add(new DefaultSqlCohortQueryLoader());
		}
		
		List<SqlCohortQuery> cohortQueries = new ArrayList<SqlCohortQuery>();
		for (SqlCohortQueryLoader loader : loaders) {
			try {
				cohortQueries.addAll(loader.load());
			}
			catch (IOException e) {
				throw new APIException("Failed to load some cohort queries by SqlQueryLoader: " + loader, e);
			}
		}
		
		for (SqlCohortQuery cohortQuery : cohortQueries) {
			if (StringUtils.isBlank(cohortQuery.getName())) {
				throw new APIException("Failed to load cohort query because of missing name field");
			} else if (StringUtils.isBlank(cohortQuery.getSql())) {
				throw new APIException("Failed to load cohort query because of missing sql field");
			}
			
			List<SqlCohortDefinition> duplicates = DefinitionContext.getDefinitionService(SqlCohortDefinition.class)
			        .getDefinitions(cohortQuery.getName(), true);
			
			if (duplicates.size() == 0 || (duplicates.size() == 1 && duplicates.get(0).isRetired())) {
				CohortDefinition definition = new SqlCohortDefinition(cohortQuery.getSql());
				definition.setName(cohortQuery.getName());
				definition.setDescription(cohortQuery.getDescription());
				if (cohortQuery.getConceptMappings() != null) {
					for (String mapping : cohortQuery.getConceptMappings()) {
						definition.addParameter(new Parameter(mapping, mapping.replaceFirst(
						    CaseReportConstants.CONCEPT_MAPPING_SEPARATOR, ":"), Integer.class));
					}
				}
				DefinitionContext.saveDefinition(definition);
				addSchedulerTaskIfNecessary(cohortQuery.getName(), cohortQuery.getRepeatInterval());
			}
		}
	}
	
	private void addSchedulerTaskIfNecessary(String name, Long repeatInterval) {
		log.info("Creating Case Reports Task for: " + name);
		
		SchedulerService ss = Context.getSchedulerService();
		String className = CaseReportTask.class.getName();
		String description = Context.getMessageSourceService().getMessage("casereport.description.schedulerTaskFor",
		    new Object[] { name }, null, null);
		TaskDefinition td = ss.getTaskByName(name);
		if (td == null || !className.equals(className)) {
			td = new TaskDefinition(null, name, description, className);
			td.setStartOnStartup(false);
			td.setProperty(CaseReportConstants.TRIGGER_NAME_TASK_PROPERTY, name);
			td.setRepeatInterval(repeatInterval);
			if (td.getRepeatInterval() == null) {
				td.setRepeatInterval(0L);
			}
			ss.saveTaskDefinition(td);
		}
	}
	
	/**
	 * @see ModuleActivator#willStart()
	 */
	public void willStart() {
		log.info("Starting Case Report Module");
	}
	
	/**
	 * @see ModuleActivator#started()
	 */
	public void started() {
		log.info("Case Report Module started");
	}
	
	/**
	 * @see ModuleActivator#willStop()
	 */
	public void willStop() {
		log.info("Stopping Case Report Module");
	}
	
	/**
	 * @see ModuleActivator#stopped()
	 */
	public void stopped() {
		log.info("Case Report Module stopped");
	}
	
}
