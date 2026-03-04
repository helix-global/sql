using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateUserOption))]
    internal sealed class SqlScriptCreateUserOption : SqlScriptCodeObject<SqlCreateUserOption>
        {
        #region ctor{IServiceProvider,SqlCreateUserOption}
        public SqlScriptCreateUserOption(IServiceProvider context,SqlCreateUserOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }