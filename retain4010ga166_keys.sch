"Audit"	"PRIMARY"
"Audit"	"idt"
"Audit"	"iaui"
"Audit"	"itui"
"Audit"	"iip"
"Audit"	"ia"
"Audit"	"ina"
"Audit"	"iid"
"legacy_ids"	"PRIMARY"
"legacy_ids"	"fk_message_id_li"
"legacy_ids"	"idx_old_email_id_li"
"s_AddressBookCache"	"PRIMARY"
"s_AddressBookCache"	"idx_displayName_abc"
"s_AddressBookCache"	"idx_mailbox_abc"
"s_AddressBookCache"	"idx_email_abc"
"s_AddressBookCache"	"idx_uid_abc"
"s_ErrorItemFolders"	"PRIMARY"
"s_ErrorItemFolders"	"Name"
"s_ErrorItems"	"PRIMARY"
"s_ErrorItems"	"FK_ErrorItemFolderID"
"s_ErrorItems"	"FK_AddressBookCacheID"
"s_ErrorItems"	"FK_MailboxRunErrorID"
"s_ErrorItems"	"FK_JobRunErrorID"
"s_ErrorItems"	"idx_attachment_name"
"s_Errors"	"PRIMARY"
"s_Errors"	"idx_name_e"
"s_Errors"	"idx_severity"
"s_Errors"	"idx_code"
"s_Errors"	"idx_name"
"s_Errors"	"idx_description"
"s_FlagUpdates"	"PRIMARY"
"s_FlagUpdates"	"FK_JobRuns"
"s_FlagUpdates"	"FK_MailboxRuns"
"s_FlagUpdates"	"FK_AddressBookCache"
"s_JobRunErrors"	"PRIMARY"
"s_JobRunErrors"	"FK_ErrorID"
"s_JobRunErrors"	"FK_JobRunID"
"s_JobRunIncrements"	"PRIMARY"
"s_JobRunIncrements"	"FK_JobRunID2"
"s_JobRuns"	"PRIMARY"
"s_JobRuns"	"FK_JobsCacheID"
"s_JobRuns"	"idx_status"
"s_JobsCache"	"PRIMARY"
"s_JobsCache"	"idx_JobNativeID_jc"
"s_MailboxRunErrors"	"PRIMARY"
"s_MailboxRunErrors"	"FK_ErrorID2"
"s_MailboxRunErrors"	"FK_MailboxRunID"
"s_MailboxRunIncrements"	"PRIMARY"
"s_MailboxRunIncrements"	"FK_MailboxRunID2"
"s_MailboxRuns"	"PRIMARY"
"s_MailboxRuns"	"FK_JobRunID3"
"s_MailboxRuns"	"FK_AddressBookCacheID2"
"s_ReportGenerationCount"	"PRIMARY"
"s_ScheduledParameters"	"PRIMARY"
"s_ScheduledParameters"	"FK_ScheduledReportID2"
"s_ScheduledRecipients"	"PRIMARY"
"s_ScheduledRecipients"	"FK_ScheduledReportID"
"s_ScheduledReports"	"PRIMARY"
"s_ServerUsage"	"PRIMARY"
"s_ServerUsage"	"FK_ServerID"
"s_ServerUsageMetrics"	"PRIMARY"
"s_ServerUsageMetrics"	"FK_ServerUsageId"
"s_Servers"	"PRIMARY"
"t_Part"	"PRIMARY"
"t_Part"	"sid"
"t_Part"	"bt"
"t_abook"	"PRIMARY"
"t_abook"	"I_ABPO"
"t_abook"	"I_ABL"
"t_abook"	"I_ABT"
"t_abook"	"I_ABH"
"t_abook"	"I_ABST"
"t_abook"	"I_ABDO"
"t_abook"	"I_ABM"
"t_abook"	"I_ABF"
"t_abook"	"I_ABLC"
"t_abook"	"I_ABOOK"
"t_abook"	"I_ABEM"
"t_abook"	"I_ABD"
"t_abook"	"FKAB2PO"
"t_abook"	"FKAB2DOM"
"t_abook"	"I_ABDN"
"t_abook"	"I_ABIDOM"
"t_aclrights"	"PRIMARY"
"t_aclrights"	"I_ACLRIGHTS"
"t_appuid"	"PRIMARY"
"t_appuid"	"I_AMEUD"
"t_appuid"	"I_INTUIDK"
"t_appuid"	"I_AMEUDI"
"t_appuid"	"FKAPPUID2INTUID"
"t_audit_properties"	"PRIMARY"
"t_audit_properties"	"FK1F3BB882C8C8A05F"
"t_audit_properties"	"iidt"
"t_comments"	"PRIMARY"
"t_comments"	"I_UC"
"t_datetimeformats"	"PRIMARY"
"t_dbinfo"	"PRIMARY"
"t_dbinfoproperties"	"PRIMARY"
"t_dbinfoproperties"	"I_DBINFO"
"t_deletion"	"PRIMARY"
"t_deletion"	"isid"
"t_deletion"	"ieid"
"t_deletion"	"isd"
"t_deletion"	"ist"
"t_device_properties"	"PRIMARY"
"t_device_properties"	"fk_device_id_ma"
"t_device_properties"	"idx_revdp"
"t_device_properties"	"i_devprop_"
"t_device_properties"	"name"
"t_devices"	"PRIMARY"
"t_devices"	"i_dev_id"
"t_devices"	"i_dev_code"
"t_devices"	"i_dev_uid"
"t_devices"	"i_dev_reg"
"t_dl"	"PRIMARY"
"t_dl"	"I_DLPO"
"t_dl"	"FKDL2PO"
"t_dlmembers"	"PRIMARY"
"t_dlmembers"	"I_DLMEMBERS"
"t_dlmembers"	"FKDLMEM2DL"
"t_dlmembers"	"FKDLMEM2AB"
"t_document"	"PRIMARY"
"t_document"	"idx_hash_d"
"t_document"	"idx_tag_d"
"t_document"	"idx_refcount_d"
"t_domains"	"PRIMARY"
"t_dscnt"	"PRIMARY"
"t_dscnt"	"idx_containerType_dsc"
"t_dsref"	"PRIMARY"
"t_dsref"	"fk_ds_container_id_dsr"
"t_dsref"	"idx_usage_dsr"
"t_dsref"	"idx_size_dsr"
"t_dsref"	"idx_hash_dsr"
"t_engines"	"PRIMARY"
"t_engines"	"I_ENG"
"t_errormessages"	"PRIMARY"
"t_errormessages"	"FK342542C92A9299"
"t_errormessages"	"FKMB"
"t_exchobj"	"PRIMARY"
"t_exchobj"	"I_EOS"
"t_exchobj"	"I_EOU"
"t_exchobj"	"I_EOBJT"
"t_folder"	"PRIMARY"
"t_folder"	"fk_uuid_mapping_id_f"
"t_folder"	"fk_parent_id_f"
"t_folder"	"idx_uuid_parent_f"
"t_group"	"PRIMARY"
"t_group"	"I_GNAME"
"t_groupprops"	"PRIMARY"
"t_groupprops"	"I_GRPPROPS"
"t_groupprops"	"I_GPROPS"
"t_groupprops"	"FKGRPPROP2GRP"
"t_grpacl"	"PRIMARY"
"t_grpacl"	"IR_GACL"
"t_grpacl"	"FKGRPACL2USER"
"t_grpmembers"	"PRIMARY"
"t_grpmembers"	"I_GRPMEM"
"t_grpmembers"	"I_GRPMEMU"
"t_grpmembers"	"IR_GRPFK"
"t_grpmembers"	"FKGRPMEM2GRP"
"t_grpuid"	"PRIMARY"
"t_grpuid"	"IG_PCHECK"
"t_grpuid"	"IG_USUID"
"t_grpuid"	"IR_GRID"
"t_grpuid"	"FKGRPUID2USER"
"t_handlers"	"PRIMARY"
"t_index"	"PRIMARY"
"t_index"	"FKHIND2HAND"
"t_intuid"	"PRIMARY"
"t_intuid"	"I_IMIUD"
"t_intuid"	"I_BUIDK"
"t_intuid"	"FKINTUID2BASE"
"t_jobmailboxes"	"PRIMARY"
"t_jobmailboxes"	"FK_AddressBookID2"
"t_jobmailboxes"	"FKJOBMB"
"t_jobmailboxes"	"started_idx"
"t_jobmembers"	"PRIMARY"
"t_jobmembers"	"f_type"
"t_jobmembers"	"FKJOBMEM2JOB"
"t_joboptions"	"PRIMARY"
"t_joboptions"	"I_JOBOP"
"t_joboptions"	"FKJOBOPT2JOB"
"t_jobs"	"PRIMARY"
"t_jobs"	"I_JOB"
"t_languages"	"PRIMARY"
"t_message"	"PRIMARY"
"t_message"	"fk_folder_id_mf"
"t_message"	"fk_uuid_mapping_id_mf"
"t_message"	"fk_message_id_m"
"t_message"	"idx_message_natural_id_m"
"t_message"	"idx_thread_m"
"t_message"	"idx_uuid_relevant_m"
"t_message"	"idx_fid_uuid_rel_m"
"t_message"	"idx_indexed_m"
"t_message"	"idx_stored_m"
"t_message_attachments"	"PRIMARY"
"t_message_attachments"	"fk_document_id_ma"
"t_message_attachments"	"fk_message_id_ma"
"t_message_properties"	"PRIMARY"
"t_message_properties"	"fk_message_id_mp"
"t_message_properties"	"fk_value_id_mp"
"t_message_properties"	"fk_name_id_mp"
"t_message_recipients"	"PRIMARY"
"t_message_recipients"	"fk_recipient_id_mr"
"t_message_recipients"	"fk_message_id_mr"
"t_message_tags"	"PRIMARY"
"t_message_tags"	"fk_tag_id_mt"
"t_message_tags"	"fk_message_id_mt"
"t_message_tags"	"fk_uuid_mapping_id_tt"
"t_modopt"	"PRIMARY"
"t_modopt"	"FKMODPROP2MOD"
"t_modopt"	"I_MODPN"
"t_modopt"	"I_MODPRS"
"t_modopt"	"I_MODPC"
"t_modopt"	"I_MODG"
"t_modules"	"PRIMARY"
"t_modules"	"I_MBTYPE"
"t_name"	"PRIMARY"
"t_name"	"f_name"
"t_notify"	"PRIMARY"
"t_notify"	"inotuid"
"t_notify"	"inotuser"
"t_notify"	"inottime"
"t_notify"	"inotid"
"t_notify"	"inottype"
"t_postoffices"	"PRIMARY"
"t_postoffices"	"FKPO2DOM"
"t_profiles"	"PRIMARY"
"t_profiles"	"I_PROFILES"
"t_recipient"	"PRIMARY"
"t_recipient"	"fk_uuid_mapping_id_r"
"t_recipient"	"idx_rMail_uuid_r"
"t_recipient"	"idx_refcount_r"
"t_schedule"	"PRIMARY"
"t_schedule"	"I_SCHEDWHEN"
"t_scheduleoptions"	"PRIMARY"
"t_scheduleoptions"	"I_SCHEDULEOPTIONS"
"t_shared"	"PRIMARY"
"t_shared"	"I_SHSH"
"t_shared"	"I_SHHS"
"t_shared"	"I_SHNM"
"t_sql"	"PRIMARY"
"t_sql"	"I_SQL"
"t_sql"	"FKSQL2USER"
"t_tagdefs"	"PRIMARY"
"t_tagdefs"	"fk_uuid_mapping_id_t"
"t_tagdefs"	"idx_natkey_td"
"t_tagdefs"	"idx_crea_scope_td"
"t_tagdefs"	"idx_scope_td"
"t_uidbase"	"PRIMARY"
"t_user"	"PRIMARY"
"t_user"	"I_UL"
"t_user"	"I_LL"
"t_useracl"	"PRIMARY"
"t_useracl"	"IR_ACLN"
"t_useracl"	"FKUSERACL2USER"
"t_userproperties"	"PRIMARY"
"t_userproperties"	"I_USERPROPERTIES"
"t_userproperties"	"I_USERPRS"
"t_userproperties"	"FKUSERPROP2USER"
"t_useruid"	"PRIMARY"
"t_useruid"	"IRUUID"
"t_useruid"	"I_PCHECK"
"t_useruid"	"I_USUID"
"t_useruid"	"FKUSERUID2USER"
"t_uuid_mapping"	"PRIMARY"
"t_uuid_mapping"	"f_uuid"
"t_value"	"PRIMARY"
"t_value"	"f_value"
"t_value"	"idx_refcount_v"
"t_workeropt"	"PRIMARY"
"t_workeropt"	"I_WORKER"
"t_workeropt"	"I_WORKPRS"
"t_workeropt"	"FKWORKPROP2WORK"
"t_workers"	"PRIMARY"
"t_workers"	"I_WORKERI"
"t_workers"	"I_WORKERF"