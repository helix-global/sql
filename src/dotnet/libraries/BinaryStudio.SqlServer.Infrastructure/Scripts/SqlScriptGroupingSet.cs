using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptGroupingSet<T> : SqlScriptCodeObject<T>
        where T : SqlGroupingSet
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptGroupingSet(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }