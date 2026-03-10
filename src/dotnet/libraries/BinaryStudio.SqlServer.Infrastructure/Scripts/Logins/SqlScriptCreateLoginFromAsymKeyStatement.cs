using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(SqlCreateLoginFromAsymKeyStatement))]
    internal sealed class SqlScriptCreateLoginFromAsymKeyStatement : SqlScriptCreateLoginStatement<SqlCreateLoginFromAsymKeyStatement>
        {
        #region ctor{IServiceProvider,SqlCreateLoginFromAsymKeyStatement}
        public SqlScriptCreateLoginFromAsymKeyStatement(IServiceProvider context,SqlCreateLoginFromAsymKeyStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }