using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptFullTextColumn : SqlScriptCodeObject<SqlFullTextColumn>
        {
        #region ctor{IServiceProvider,SqlFullTextColumn}
        public SqlScriptFullTextColumn(IServiceProvider context,SqlFullTextColumn source)
            : base(context,source)
            {
            }
        #endregion
        }
    }