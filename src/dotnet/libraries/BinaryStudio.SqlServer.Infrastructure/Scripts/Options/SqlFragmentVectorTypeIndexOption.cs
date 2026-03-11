using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(VectorTypeIndexOption))]
    internal sealed class SqlScriptDomVectorTypeIndexOption : SqlScriptDomIndexOption<VectorTypeIndexOption>
        {
        #region ctor{IServiceProvider,VectorTypeIndexOption}
        public SqlScriptDomVectorTypeIndexOption(IServiceProvider context,VectorTypeIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }