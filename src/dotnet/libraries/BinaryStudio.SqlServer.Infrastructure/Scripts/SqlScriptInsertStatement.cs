using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlInsertStatement))]
    internal sealed class SqlScriptInsertStatement : SqlScriptDmlStatement<SqlInsertStatement>
        {
        #region ctor{IServiceProvider,SqlInsertStatement}
        public SqlScriptInsertStatement(IServiceProvider context,SqlInsertStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }