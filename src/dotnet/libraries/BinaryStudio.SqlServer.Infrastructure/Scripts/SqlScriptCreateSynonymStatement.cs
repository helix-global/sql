using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptCreateSynonymStatement : SqlScriptDdlStatement<SqlCreateSynonymStatement>
        {
        #region ctor{IServiceProvider,SqlCreateSynonymStatement}
        public SqlScriptCreateSynonymStatement(IServiceProvider context,SqlCreateSynonymStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }