using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptMergeAction<T> : SqlScriptCodeObject<T>
        where T : SqlMergeAction
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptMergeAction(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }