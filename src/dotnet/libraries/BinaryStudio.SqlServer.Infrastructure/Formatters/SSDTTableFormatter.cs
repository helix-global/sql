using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using static BinaryStudio.SqlServer.Infrastructure.SqlIdentifier;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SSDTTableFormatter : SqlObjectFormatter<ISqlTable>
        {
        public static readonly ISqlObjectFormatter<ISqlTable> Instance = new SSDTTableFormatter();

        #region M:WriteTo(IServiceProvider,T,TextWriter)
        public override void WriteTo(IServiceProvider provider,ISqlTable source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            var PropertyProvider = (ISqlExtendedPropertyResolver)provider?.GetService(typeof(ISqlExtendedPropertyResolver));
            target.WriteLine($"CREATE TABLE {source.QualifiedName} (");
            var namvl = new String[source.Columns.Count];
            var typvl = new String[namvl.Length];
            var nulvl = new String[namvl.Length];
            var idevl = new String[namvl.Length];
            var colvl = new List<String>();
            var extpr = new List<String>();
            var namsz = 0;
            var typsz = 0;
            var nulsz = 0;
            var idesz = 0;
            var j = 0;
            foreach (var column in source.Columns) {
                namvl[j] = $"[{column.Name}]";
                typvl[j] = column.IsComputed ? "AS" : column.TypeSpecifier.ToString(SSDTTypeSpecifierFormatter.Instance);
                if (column.IsComputed)
                    {
                    nulvl[j] = $" {((ISqlComputedColumn)column).Expression}";
                    }
                else
                    {
                    var r = new StringBuilder();
                    foreach (var constraint in column.Constraints) {
                        switch (constraint.Type) {
                            case SqlConstraintType.NotNull : { r.Append(" NOT NULL");} break;
                            case SqlConstraintType.Null    : { r.Append(" NULL");    } break;
                            case SqlConstraintType.Identity: break;
                            case SqlConstraintType.Default:
                                {
                                if ((m_DF.TryGetValue(column.QualifiedName.ToString(),out var name)) || (constraint.Name != Null)) {
                                    r.Append($" CONSTRAINT [{constraint.Name?.ToString()??name}]");
                                    }
                                r.Append($" DEFAULT {((ISqlDefaultConstraint)constraint).Expression}");
                                }
                                break;
                            default: throw new NotSupportedException();
                            }
                        }
                    nulvl[j] = r.ToString();
                    }

                if (PropertyProvider != null) {
                    var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Column,column.QualifiedName,"MS_Description"));
                    if (prop != null) {
                        extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}', @level2type = N'COLUMN', @level2name = N'{column.Name}'");
                        }
                    }

                var identity = column.Constraints.FirstOrDefault(i => i.Type == SqlConstraintType.Identity);
                idevl[j] = (identity != null)? $" {identity.ToString(SSDTConstraintFormatter.Instance)}" : String.Empty;

                namsz = Math.Max(namsz,namvl[j].Length);
                typsz = Math.Max(typsz,typvl[j].Length);
                nulsz = Math.Max(nulsz,nulvl[j].Length);
                idesz = Math.Max(idesz,idevl[j].Length);
                j++;
                }
            for (j=0;j < namvl.Length;j++) {
                colvl.Add(String.Format($"{{0,-{namsz}}} {{1,-{typsz}}}{{3}}{{2}}",
                    namvl[j],
                    typvl[j],
                    nulvl[j],
                    idevl[j]));
                }

            if (PropertyProvider != null) {
                var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Table,source.QualifiedName,"MS_Description"));
                if (prop != null) {
                    extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}'");
                    }
                }

            #region PRIMARY KEY
            foreach (var constraint in source.Constraints.OfType<ISqlScriptUniqueConstraint>().Where(i=>i.Type == SqlConstraintType.PrimaryKey)) {
                var r = new StringBuilder();
                if ((m_PK.TryGetValue(source.QualifiedName.ToString(),out var name)) ||(constraint.Name != Null))
                    {
                    r.Append($"CONSTRAINT [{constraint.Name?.ToString()??name}] ");
                    }
                r.Append($"PRIMARY KEY");
                r.Append(IsClustered(constraint.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.IndexedColumns.Select(i => $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                r.Append(")");
                if (constraint.IndexOptions.Any()) {
                    r.Append(" WITH");
                    foreach (var option in constraint.IndexOptions) {
                        switch (option.Type) {
                            case SqlIndexOptionType.FillFactor: { r.Append($" (FILLFACTOR = {((ISqlFillFactorIndexOption)option).FillFactor})"); } break;
                            default: throw new NotSupportedException();
                            }
                        }
                    }
                colvl.Add(r.ToString());
                }
            #endregion
            #region CHECK CONSTRAINT
            foreach (var constraint in source.Constraints.OfType<ISqlCheckConstraint>().Where(i=>i.Type == SqlConstraintType.Check)) {
                var r = new StringBuilder();
                if (constraint.Name != Null)
                    {
                    r.Append($"CONSTRAINT [{constraint.Name}] ");
                    }
                r.Append($"CHECK");
                r.Append($" ({constraint.Expression})");
                colvl.Add(r.ToString());
                }
            #endregion
            #region FOREIGN KEY
            foreach (var constraint in source.Constraints.OfType<ISqlForeignKeyConstraint>()) {
                var r = new StringBuilder();
                r.Append($"CONSTRAINT [{constraint.Name}] FOREIGN KEY");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.Columns.Select(i => $"[{i}]")));
                r.Append($") REFERENCES {constraint.ReferencedTable} (");
                r.Append(String.Join(", ",constraint.ReferencedColumns.Select(i => $"[{i}]")));
                r.Append(")");
                if (constraint.DeleteAction != SqlForeignKeyAction.NoAction) {
                    r.Append(" ON DELETE ");
                    switch (constraint.DeleteAction) {
                        case SqlForeignKeyAction.Cascade   : { r.Append("CASCADE");     } break;
                        case SqlForeignKeyAction.SetNull   : { r.Append("SET NULL");    } break;
                        case SqlForeignKeyAction.SetDefault: { r.Append("SET DEFAULT"); } break;
                        default: throw new ArgumentOutOfRangeException();
                        }
                    }
                if (constraint.UpdateAction != SqlForeignKeyAction.NoAction) {
                    r.Append(" ON UPDATE ");
                    switch (constraint.DeleteAction) {
                        case SqlForeignKeyAction.Cascade   : { r.Append("CASCADE");     } break;
                        case SqlForeignKeyAction.SetNull   : { r.Append("SET NULL");    } break;
                        case SqlForeignKeyAction.SetDefault: { r.Append("SET DEFAULT"); } break;
                        default: throw new ArgumentOutOfRangeException();
                        }
                    }
                colvl.Add(r.ToString());
                }
            #endregion
            #region UNIQUE CONSTRAINT
            foreach (var constraint in source.Constraints.OfType<ISqlScriptUniqueConstraint>().Where(i=>i.Type == SqlConstraintType.Unique)) {
                var r = new StringBuilder();
                if (constraint.Name != Null)
                    {
                    r.Append($"CONSTRAINT [{constraint.Name}] ");
                    }
                r.Append($"UNIQUE");
                r.Append(IsClustered(constraint.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.IndexedColumns.Select(i => $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                r.Append(")");
                if (constraint.IndexOptions.Any()) {
                    r.Append(" WITH");
                    foreach (var option in constraint.IndexOptions) {
                        switch (option.Type) {
                            case SqlIndexOptionType.FillFactor: { r.Append($" (FILLFACTOR = {((ISqlFillFactorIndexOption)option).FillFactor})"); } break;
                            default: throw new NotSupportedException();
                            }
                        }
                    }
                colvl.Add(r.ToString());
                }
            #endregion

            namsz = colvl.Count - 1;
            typsz = source.Columns.Count;

            j = 0;
            foreach (var col in colvl) {
                target.Write("    ");
                target.Write(col);
                target.Write((j == namsz) ? "" : ",");
                target.WriteLine();
                j++;
                }
            target.WriteLine(");");
            target.WriteLine();

            #region CREATE INDEX
            foreach (var index in source.Indexes.OrderByDescending(i=>i.Name)) {
                if (source.Constraints.Any(i => SqlIdentifier.Equals(i.Name,index.Name))) { continue; }
                target.WriteLine();
                target.WriteLine("GO");
                target.Write("CREATE");
                if (index.IsUnique)
                    {
                    target.Write(" UNIQUE");
                    }
                target.Write(IsClustered(index.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                target.WriteLine($" INDEX [{index.Name}]");
                target.Write($"    ON {index.TargetObject}(");
                target.Write(String.Join(", ",index.IndexedColumns.Select(i=> $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                target.Write(")");
                if (index.IncludedColumns.Any()) {
                    target.WriteLine();
                    target.Write("    INCLUDE(");
                    target.Write(String.Join(", ",index.IncludedColumns.Select(i=>$"[{i}]")));
                    target.Write(")");
                    }
                if (!String.IsNullOrWhiteSpace(index.FilterExpression)) {
                    target.Write($" WHERE ({index.FilterExpression})");
                    }
                if (index.Options.Any()) {
                    target.Write(" WITH");
                    foreach (var option in index.Options) {
                        switch (option.Type) {
                            case SqlIndexOptionType.FillFactor: { target.Write($" (FILLFACTOR = {((ISqlFillFactorIndexOption)option).FillFactor})"); } break;
                            default: throw new NotSupportedException();
                            }
                        }
                    }
                target.WriteLine(";");
                target.WriteLine();

                if (PropertyProvider != null) {
                    var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Index,index.QualifiedName,"MS_Description"));
                    if (prop != null) {
                        extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}', @level2type = N'INDEX', @level2name = N'{index.Name}'");
                        }
                    }
                }
            #endregion
            #region CREATE TRIGGER
            foreach (var trigger in source.Triggers) {
                target.WriteLine();
                target.WriteLine("GO");
                target.Write(((ISqlScriptCodeObject)trigger).Script);
                }
            #endregion

            foreach (var e in extpr) {
                target.WriteLine();
                target.WriteLine("GO");
                target.Write(e);
                target.WriteLine(";");
                target.WriteLine();
                }
            }
        #endregion
        #region M:IsClustered(SqlClusterOption):Boolean
        private static Boolean IsClustered(SqlClusterOption value) {
            return (value == SqlClusterOption.Clustered)
                || (value == SqlClusterOption.ClusteredColumnStore);
            }
        #endregion

        private readonly IDictionary<String,String> m_DF = new SortedDictionary<String,String> {
            {"[dbo].[COM_CURRENCIES].[GID]","DF__COM_CURRENC__GID__37A5467C" },
            {"[dbo].[COM_SKILLS].[ITERATIONS_REPEAT]","DF_COM_SKILLS_ITERATIONS_REPEAT" },
            {"[dbo].[IT_TASK_COMMENT_READ].[DATEREAD]","DF_IT_TASK_COMMENT_READ_DATEREAD" },
            {"[dbo].[MOBILE_PUSH_MESSAGES].[CR_DT]","DF_MOBILE_PUSH_MESSAGES_CR_DT" },
            {"[dbo].[MOBILE_PUSH_TOKENS].[UpdateDT]","DF_temp_PUSH_UpdateDT" },
            {"[dbo].[MOBILE_PUSH_TOKENS_LOG].[InsertDT]","DF_temp_PUSH_LOG_InsertDT" },
            {"[dbo].[PR_OPERATION_PARAMS_BACKUP_KB3439_TEMP].[CONVERTED]","DF_PR_OPERATION_PARAMS_BACKUP_KB3439_TEMP_CONVERTED" },
            {"[dbo].[PR_PRINTED_REPORTS].[]","" },
            {"[dbo].[PR_PRINTED_REPORTS].[S_CDT]","DF_PR_PRINTED_REPORTS_S_CDT" },
            {"[dbo].[SM_SERVICECASE].[REMINDER_SENT]","DF_SM_SERVICECASE_REMINDER_SENT" },
            {"[dbo].[TRB_REQUESTS_CHANGES].[CHANGEDDT]","DF_TRB_REQUESTS_CHANGES_CHANGEDDT" },
            };
        private readonly IDictionary<String,String> m_PK = new SortedDictionary<String,String> {
            {"[dbo].[COM_ADDED_WORKTIME_PLAN]","PK__COM_ADDE__3214EC274E3FF3C6" },
            {"[dbo].[COM_ADDED_WORKTIME_PLAN_T]","PK__COM_ADDE__3214EC275304A8E3" },
            {"[dbo].[COM_CALENDAR]","PK__COM_CALE__3214EC271ADEEA9C" },
            {"[dbo].[COM_CUSTOMER]","PK__COM_CUST__3214EC2740F9A68C" },
            {"[dbo].[COM_EMPL_PERIODS]","PK__COM_EMPL__3214EC276542BF51" },
            {"[dbo].[COM_SHACCOUNT_S]","PK__COM_SHAC__3214EC27475C8B58" },
            {"[dbo].[COM_VACATION]","PK__COM_VACA__3214EC275B8E6C8E" },
            {"[dbo].[COM_VACATION_CANCEL]","PK__COM_VACA__3214EC27273A9FE0" },
            {"[dbo].[COM_WDR_RESTRICT]","PK__COM_WDR___3214EC27DA909A29" },
            {"[dbo].[DA_CONCESSION]","PK__DA_CONCE__3214EC27A2CC5FC9" },
            {"[dbo].[DA_CONCESSION_SPEC_REQ]","PK__DA_CONCE__3214EC2716D5583B" },
            {"[dbo].[DEF_ASSEMBLY]","PK__DEF_ASSE__3214EC2739788055" },
            {"[dbo].[DEF_ASSEMBLY_BETA]","PK__DEF_ASSE__3214EC271492AB17" },
            {"[dbo].[DEF_ASSEMBLY_FILES_BETA]","PK__DEF_ASSE__3214EC2718633BFB" },
            {"[dbo].[DEF_CLASSES]","PK__DEF_CLAS__3214EC2733D4B598" },
            {"[dbo].[DEF_COMPANY]","PK__DEF_COMP__3214EC271771C0F0" },
            {"[dbo].[DEF_DICTIONARY]","PK__DEF_DICT__3214EC2703317E3D" },
            {"[dbo].[DEF_DICTIONARY_T]","PK__DEF_DICT__3214EC2707020F21" },
            {"[dbo].[DEF_ENTITY]","PK__DEF_ENTI__3214EC27286302EC" },
            {"[dbo].[DEF_ENTITY_FIELDS]","PK__DEF_ENTI__3214EC27300424B4" },
            {"[dbo].[DEF_INTERFACE]","PK__DEF_INTE__3214EC270AD2A005" },
            {"[dbo].[DEF_INTERFACE_T]","PK__DEF_INTE__3214EC270EA330E9" },
            {"[dbo].[DEF_MODULES]","PK__DEF_MODU__3214EC277F60ED59" },
            {"[dbo].[DEF_OPERATION]","PK__DEF_OPER__3214EC2731B762FC" },
            {"[dbo].[DEF_REPORTS]","PK__DEF_REPO__3214EC27164452B1" },
            {"[dbo].[DEF_SQL]","PK__DEF_SQL__3214EC275812160E" },
            {"[dbo].[DEF_USERS]","PK__DEF_USER__3214EC271273C1CD" },
            {"[dbo].[DEF_USERSTOGROUP]","PK__DEF_USER__3214EC271DE57479" },
            {"[dbo].[DEF_USERSTOINTERFACE]","PK__DEF_USER__3214EC271A14E395" },
            {"[dbo].[FC_A_HISTORY]","PK__FC_A_HIS__3214EC27713DB68B" },
            {"[dbo].[FC_EXT_TRANSLATION]","PK__FC_EXT_T__3214EC27299CADA8" },
            {"[dbo].[FC_FA_SUBSCRIBE]","PK__FC_FA_SU__3214EC2769F19A7E" },
            {"[dbo].[FC_REPORT]","PK__FC_MASTE__3214EC270C26B6F1" },
            {"[dbo].[PORTAL_NEWS]","PK__PORTAL_N__3214EC27CD58C30C" },
            {"[dbo].[PR_DEVICE]","PK__PR_DEVIC__3214EC277755B73D" },
            {"[dbo].[PR_DOC_SETTINGS]","PK__PR_DOC_S__3214EC2745B5055F" },
            {"[dbo].[PR_FP_PLANNING_ITEMS]","PK__PR_FP_PL__3214EC275674E380" },
            {"[dbo].[PR_FP_TURM]","PK__PR_FP_TU__3214EC27E7363D5F" },
            {"[dbo].[PR_MAP]","PK__PR_MAP__3214EC27049AA3C2" },
            {"[dbo].[PR_MAP_FLOW]","PK__PR_MAP_F__3214EC27100C566E" },
            {"[dbo].[PR_MAP_OPER]","PK__PR_MAP_O__3214EC270A537D18" },
            {"[dbo].[PR_MAP_OPER_OPT_GROUPS]","PK__PR_MAP_O__3214EC276B8B9096" },
            {"[dbo].[PR_MODELS]","PK__PR_MODEL__3214EC2757DD0BE4" },
            {"[dbo].[PR_MT_CHANGE_NOTIFY]","PK__PR_MT_CH__3214EC27D5091199" },
            {"[dbo].[PR_NAV_PN_CACHE]","PK__PR_NAV_P__3214EC273449B6E4" },
            {"[dbo].[PR_OPERATION]","PK__PR_OPERA__3214EC270697FACD" },
            {"[dbo].[PR_OPERATIONS_GR]","PK__PR_OPERA__3214EC27075714DC" },
            {"[dbo].[PR_OPERATION_INSTALL]","PK__PR_OPERA__3214EC2762AFA012" },
            {"[dbo].[PR_OPERATION_MU]","PK__PR_OPERA__3214EC2736670980" },
            {"[dbo].[PR_PRINTED_REPORTS]","PK_PR_PRINTED_REPORTS_1" },
            {"[dbo].[PR_REPORTS]","PK__PR_REPOR__3214EC27711DBAFA" },
            {"[dbo].[PU_SEARCH_ITEMS]","PK__PU_SEARC__3214EC276299DCB3" },
            {"[dbo].[REVCH_CHANGE_SW]","PK__REVCH_CH__3214EC275B02C996" },
            {"[dbo].[SH_ORDER]","PK__SH_ORDER__3214EC277E8CC4B1" },
            {"[dbo].[SH_SETTINGS_TO_CUSTOMER]","PK__SH_SETTI__3214EC2750B1B6BF" },
            {"[dbo].[SL_QUOTE]","PK__SL_QUOTE__3214EC274FFCBE51" },
            {"[dbo].[SL_QUOTE2]","PK__SL_QUOTE__3214EC277CEF6059" },
            {"[dbo].[SL_TEMPLATE]","PK__SL_TEMPL__3214EC272B403AEE" },
            {"[dbo].[SL_TEMPLATE_TO_EXPORT]","PK__SL_TEMPL__3214EC2741A512B7" },
            {"[dbo].[SM_RMA_NOTIFICATIONS]","PK__SM_RMA_N__3214EC276CAED6EF" },
            {"[dbo].[SM_SERVICECASE]","PK__SM_SERVI__3214EC2757C8C8A2" },
            {"[dbo].[SYNC2_MODELS_SETUP]","PK__SYNC2_MO__3214EC272F9ADBB7" },
            {"[dbo].[VR_ADDRESSES]","PK__VR_ADDRE__3214EC273837D926" },
            {"[dbo].[VR_REQUEST]","PK__VR_REQUE__3214EC271C342674" },
            };
        }
    }