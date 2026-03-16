using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlDeleteStatement))]
    internal sealed class SqlScriptDeleteStatement : SqlScriptDmlStatement<SqlDeleteStatement>
        {
        #region ctor{IServiceProvider,SqlDeleteStatement}
        public SqlScriptDeleteStatement(IServiceProvider context,SqlDeleteStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }