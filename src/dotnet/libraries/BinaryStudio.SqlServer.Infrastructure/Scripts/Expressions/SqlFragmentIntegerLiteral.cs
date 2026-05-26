using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(IntegerLiteral))]
    internal sealed class SqlFragmentIntegerLiteral : SqlFragmentLiteral<IntegerLiteral>
        {
        #region ctor{IServiceProvider,IntegerLiteral}
        public SqlFragmentIntegerLiteral(IServiceProvider context,IntegerLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }