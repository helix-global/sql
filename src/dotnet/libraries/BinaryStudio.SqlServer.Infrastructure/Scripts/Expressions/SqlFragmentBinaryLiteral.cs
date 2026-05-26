using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(BinaryLiteral))]
    internal sealed class SqlFragmentBinaryLiteral : SqlFragmentLiteral<BinaryLiteral>
        {
        #region ctor{IServiceProvider,BinaryLiteral}
        public SqlFragmentBinaryLiteral(IServiceProvider context,BinaryLiteral source)
            : base(context,source)
            {
            }
        #endregion
        }
    }