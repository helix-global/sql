using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlRestoreInformationStatement))]
    internal class SqlScriptRestoreInformationStatement : SqlScriptStatement<SqlRestoreInformationStatement>
        {
        #region ctor{IServiceProvider,SqlRestoreInformationStatement}
        public SqlScriptRestoreInformationStatement(IServiceProvider context,SqlRestoreInformationStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }