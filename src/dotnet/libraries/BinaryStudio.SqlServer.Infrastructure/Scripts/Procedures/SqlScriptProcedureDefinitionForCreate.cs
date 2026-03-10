using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlProcedureDefinitionForCreate))]
    internal sealed class SqlScriptProcedureDefinitionForCreate : SqlScriptProcedureDefinition<SqlProcedureDefinitionForCreate>
        {
        public Boolean IsOrAlterStatement { get { return Source.IsOrAlterStatement; }}

        #region ctor{IServiceProvider,SqlProcedureDefinitionForCreate}
        public SqlScriptProcedureDefinitionForCreate(IServiceProvider context,SqlProcedureDefinitionForCreate source)
            : base(context,source)
            {
            }
        #endregion
        }
    }